class UpdatePhoneCallStatus < ApplicationWorkflow
  NOT_ANSWERED_SIP_TERM_STATUSES = %w[ 480 487 603].freeze
  BUSY_SIP_TERM_STATUSES = [ "486" ].freeze

  class InvalidStateTransitionError < StandardError; end

  attr_reader :phone_call, :event_type, :answer_epoch, :sip_term_status, :sip_invite_failure_status, :session_limiters

  def initialize(phone_call, event_details, **options)
    super(**options)
    @phone_call = phone_call
    @event_type = event_details.fetch(:event_type).to_sym
    @answer_epoch = event_details.fetch(:answer_epoch)
    @sip_term_status = event_details.fetch(:sip_term_status)
    @sip_invite_failure_status = event_details[:sip_invite_failure_status]
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new(logger:) ] }
  end

  def call
    return handle_complete_event if event_type == :completed
    return phone_call.ring! if event_type == :ringing && phone_call.may_fire_event?(:ring)
    phone_call.answer! if event_type == :answered && phone_call.may_fire_event?(:answer)
  rescue AASM::InvalidTransition => e
    raise InvalidStateTransitionError, e.message
  end

  private

  def handle_complete_event
    if answer_epoch.to_i.positive?
      phone_call.complete!
      create_interaction
    elsif NOT_ANSWERED_SIP_TERM_STATUSES.include?(sip_term_status)
      phone_call.mark_as_not_answered!
    elsif BUSY_SIP_TERM_STATUSES.include?(sip_term_status)
      phone_call.mark_as_busy!
    elsif NOT_ANSWERED_SIP_TERM_STATUSES.include?(sip_invite_failure_status)
      phone_call.cancel!
    else
      phone_call.fail!
    end

    session_limit
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

  def session_limit
    return if phone_call.region.blank?

    session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
  end
end
