class CreatePhoneCallEventJob < ApplicationJob
  class Handler
    class PhoneCallNotFoundError < StandardError; end
    class InvalidStateTransitionError < StandardError; end

    attr_reader :phone_call_external_id, :params

    def initialize(phone_call_external_id:, **params)
      @phone_call_external_id = phone_call_external_id
      @params = params
    end

    def perform
      event = create_event!
      update_phone_call_status(event)
    end

    private

    def create_event!
      PhoneCallEvent.create!(phone_call:, **params)
    end

    def phone_call
      @phone_call ||= PhoneCall.find_by!(external_id: phone_call_external_id)
    rescue ActiveRecord::RecordNotFound => e
      raise PhoneCallNotFoundError, e.message
    end

    def update_phone_call_status(event)
      case event.type
      when "ringing"
        phone_call.ring!
      when "answered"
        phone_call.answer!
      end
    rescue AASM::InvalidTransition => e
      raise InvalidStateTransitionError, e.message
    end
  end

  def perform(...)
    Handler.new(...).perform
  end

  retry_on(Handler::PhoneCallNotFoundError,  wait: :polynomially_longer, attempts: 3)
  discard_on(Handler::InvalidStateTransitionError)
end
