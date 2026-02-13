class ProcessCDRJob < ApplicationJob
  queue_as(AppSettings.fetch(:aws_sqs_medium_priority_queue_name))

  class Handler
    class PhoneCallNotFoundError < StandardError; end
    class UnknownPhoneCallError < StandardError; end
    class CDRAlreadyExistsError < StandardError; end

    attr_accessor :raw_payload, :cdr, :session_limiters

    def initialize(raw_payload, **options)
      @raw_payload = raw_payload
      @cdr = decode_payload
      @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
    end

    def perform
      return if proxy_leg?

      phone_call = find_phone_call
      create_call_data_record(phone_call)
      session_limit(phone_call)
      CompletePhoneCallJob.perform_later(phone_call)
    end

    private

    def create_call_data_record(phone_call)
      CallDataRecord.create!(
        phone_call:,
        external_id: cdr_variables.fetch("uuid"),
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

    def find_phone_call
      phone_call_id = cdr_variables["sip_rh_X-Somleng-CallSid"]
      phone_call_id ||= cdr_variables["sip_h_X-Somleng-CallSid"]

      return (PhoneCall.find_by(id: phone_call_id) || raise(PhoneCallNotFoundError)) if phone_call_id.present?

      PhoneCall.find_by(external_id: cdr_variables.fetch("uuid")) || raise(UnknownPhoneCallError)
    end

    def cdr_variables
      cdr.fetch("variables")
    end

    def parse_epoch(epoch)
      epoch = epoch.to_i
      Time.at(epoch) if epoch.positive?
    end

    # https://github.com/signalwire/freeswitch/blob/6a13dee6f816c0b801676c084ab91942dd338cc5/src/mod/event_handlers/mod_json_cdr/mod_json_cdr.c#L316
    def decode_payload
      payload = ActiveSupport::Gzip.decompress(Base64.decode64(raw_payload))
      payload = URI.decode_www_form(payload).to_h.fetch("cdr")
      payload = Base64.decode64(payload)
      payload = payload.gsub(/:(nan)/, ":null")
      JSON.parse(payload)
    end

    def session_limit(phone_call)
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end

    def proxy_leg?
      cdr_variables.fetch("direction") == "outbound"
    end
  end

  discard_on(Handler::CDRAlreadyExistsError)
  retry_on(
    Handler::UnknownPhoneCallError,
    wait: :polynomially_longer,
    attempts: 3
  )

  def perform(...)
    Handler.new(...).perform
  end
end
