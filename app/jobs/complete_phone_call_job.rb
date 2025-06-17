class CompletePhoneCallJob < ApplicationJob
  class Handler
    class InvalidStateTransitionError < StandardError; end

    NOT_ANSWERED_SIP_TERM_STATUSES = %w[ 480 487 603].freeze
    BUSY_SIP_TERM_STATUSES = [ "486" ].freeze

    attr_reader :phone_call

    def initialize(phone_call)
      @phone_call = phone_call
    end

    def perform
      return unless phone_call.uncompleted?

      update_phone_call_status
      notify_status_callback_url
      create_event
    end

    private

    def update_phone_call_status
      if call_data_record.answer_time.to_i.positive?
        phone_call.complete!
        create_interaction
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

    def create_interaction
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

    def notify_status_callback_url
      return if phone_call.status_callback_url.blank?

      ExecuteWorkflowJob.set(
        queue: AppSettings.fetch(:aws_sqs_high_priority_queue_name)
      ).perform_later(
        TwilioAPI::NotifyWebhook.to_s,
        account: phone_call.account,
        url: phone_call.status_callback_url,
        http_method: phone_call.status_callback_method,
        params: TwilioAPI::Webhook::VoiceStatusCallbackSerializer.new(
          PhoneCallDecorator.new(phone_call)
        ).serializable_hash
      )
    end

    def create_event
      CreateEvent.call(eventable: phone_call, type: "phone_call.completed")
    end

    def call_data_record
      phone_call.call_data_record
    end
  end

  queue_as(AppSettings.fetch(:aws_sqs_high_priority_queue_name))

  def perform(...)
    Handler.new(...).perform
  end

  retry_on(
    Handler::InvalidStateTransitionError,
    wait: :polynomially_longer,
    attempts: 3
  )
end
