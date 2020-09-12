class UpdatePhoneCallStatus < ApplicationWorkflow
  NOT_ANSWERED_SIP_TERM_STATUSES = %w[
    480 487 603
  ].freeze

  BUSY_SIP_TERM_STATUSES = [
    "486"
  ].freeze

  attr_reader :phone_call, :event_type, :answer_epoch, :sip_term_status

  def initialize(phone_call, event_details)
    @phone_call = phone_call
    @event_type = event_details.fetch(:event_type).to_sym
    @answer_epoch = event_details.fetch(:answer_epoch)
    @sip_term_status = event_details.fetch(:sip_term_status)
  end

  def call
    return handle_complete_event if event_type == :completed
    return phone_call.ring!      if event_type == :ringing
    return phone_call.answer!    if event_type == :answered
  end

  private

  def handle_complete_event
    return phone_call.complete!             if answer_epoch.to_i.positive?
    return phone_call.mark_as_not_answered! if NOT_ANSWERED_SIP_TERM_STATUSES.include?(sip_term_status)
    return phone_call.mark_as_busy!         if BUSY_SIP_TERM_STATUSES.include?(sip_term_status)

    phone_call.fail!
  end
end
