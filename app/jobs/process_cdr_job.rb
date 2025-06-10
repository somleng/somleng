class ProcessCDRJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_medium_priority_queue_name)

  class Handler
    class PhoneCallNotFoundError < StandardError; end
    class UnknownPhoneCallError < StandardError; end
    class InvalidStateTransitionError < StandardError; end
    class CDRAlreadyExistsError < StandardError; end

    NOT_ANSWERED_SIP_TERM_STATUSES = %w[ 480 487 603].freeze
    BUSY_SIP_TERM_STATUSES = [ "486" ].freeze

    attr_accessor :raw_payload, :cdr, :session_limiters

    def initialize(raw_payload, **options)
      @raw_payload = raw_payload
      @cdr = decode_payload
      @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
    end

    def perform
      call_data_record = create_call_data_record
      update_phone_call_status(call_data_record)
      session_limit(call_data_record.phone_call)
      notify_status_callback_url(call_data_record.phone_call)
      create_event(call_data_record.phone_call)
    end

    private

    def create_call_data_record
      CallDataRecord.create!(
        phone_call: find_phone_call,
        hangup_cause: cdr_variables.fetch("hangup_cause"),
        direction: cdr_variables.fetch("direction"),
        duration_sec: cdr_variables.fetch("duration"),
        bill_sec: cdr_variables.fetch("billsec"),
        start_time: parse_epoch(cdr_variables.fetch("start_epoch")),
        end_time: parse_epoch(cdr_variables.fetch("end_epoch")),
        answer_time: parse_epoch(cdr_variables.fetch("answer_epoch")),
        sip_term_status: cdr_variables["sip_term_status"],
        sip_invite_failure_status: cdr_variables["sip_invite_failure_status"],
        sip_invite_failure_phrase: URI.decode_www_form_component(
          cdr_variables.fetch("sip_invite_failure_phrase", "")
        ).presence,
        file: {
          io: StringIO.new(cdr.to_json),
          filename: "#{cdr_variables.fetch('uuid')}.json",
          content_type: "application/json"
        }
      )
    rescue ActiveRecord::RecordNotUnique => e
      raise CDRAlreadyExistsError, e.message
    end

    def update_phone_call_status(call_data_record)
      phone_call = call_data_record.phone_call
      if call_data_record.answer_time.to_i.positive?
        phone_call.complete!
        create_interaction(phone_call)
      elsif NOT_ANSWERED_SIP_TERM_STATUSES.include?(call_data_record.sip_term_status)
        phone_call.mark_as_not_answered!
      elsif BUSY_SIP_TERM_STATUSES.include?(call_data_record.sip_term_status)
        phone_call.mark_as_busy!
      elsif NOT_ANSWERED_SIP_TERM_STATUSES.include?(call_data_record.sip_invite_failure_status)
        phone_call.cancel!
      else
        phone_call.fail!
      end
    rescue AASM::InvalidTransition => e
      raise InvalidStateTransitionError, e.message
    end

    def create_interaction(phone_call)
      Interaction.create_or_find_by!(phone_call:) do |interaction|
        interaction.attributes = {
          interactable_type: "PhoneCall",
          carrier: phone_call.carrier,
          account: phone_call.account,
          beneficiary_country_code: phone_call.beneficiary_country_code,
          beneficiary_fingerprint: phone_call.beneficiary_fingerprint
        }
      end
    end

    def session_limit(phone_call)
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end

    def notify_status_callback_url(phone_call)
      return if phone_call.status_callback_url.blank?

      ExecuteWorkflowJob.perform_later(
        TwilioAPI::NotifyWebhook.to_s,
        account: phone_call.account,
        url: phone_call.status_callback_url,
        http_method: phone_call.status_callback_method,
        params: TwilioAPI::Webhook::VoiceStatusCallbackSerializer.new(
          PhoneCallDecorator.new(phone_call)
        ).serializable_hash
      )
    end

    def create_event(phone_call)
      CreateEvent.call(eventable: phone_call, type: "phone_call.completed")
    end

    def parse_epoch(epoch)
      epoch = epoch.to_i
      Time.at(epoch) if epoch.positive?
    end

    def find_phone_call
      phone_call_id = cdr_variables["sip_rh_X-Somleng-CallSid"]
      phone_call_id ||= cdr_variables["sip_h_X-Somleng-CallSid"]

      return (PhoneCall.find_by(id: phone_call_id) || raise(PhoneCallNotFoundError)) if phone_call_id.present?

      PhoneCall.find_by(external_id: cdr_variables.fetch("uuid")) || raise(UnknownPhoneCallError)
    end

    def cdr_variables
      cdr.fetch("variables")
    end

    # https://github.com/signalwire/freeswitch/blob/6a13dee6f816c0b801676c084ab91942dd338cc5/src/mod/event_handlers/mod_json_cdr/mod_json_cdr.c#L316
    def decode_payload
      payload = ActiveSupport::Gzip.decompress(Base64.decode64(raw_payload))
      payload = URI.decode_www_form(payload).to_h.fetch("cdr")
      payload = Base64.decode64(payload)
      payload = payload.gsub(/:(nan)/, ":null")
      JSON.parse(payload)
    end
  end

  retry_on(
    Handler::UnknownPhoneCallError,
    Handler::InvalidStateTransitionError,
    wait: :polynomially_longer
  )

  discard_on(Handler::CDRAlreadyExistsError)

  def perform(...)
    Handler.new(...).perform
  end
end
