class ProcessPhoneCallEvent < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    super()
    @params = params
  end

  def call
    params[:phone_call] = find_phone_call!
    create_event!
  end

  private

  def find_phone_call!
    PhoneCall.find_by!(external_id: params.fetch(:phone_call))
  end

  def create_event!
    ApplicationRecord.transaction do
      event = PhoneCallEvent.create!(params)
      UpdatePhoneCallStatus.call(
        event.phone_call,
        {
          event_type: event.type,
          answer_epoch: event.params["answer_epoch"],
          sip_term_status: event.params["sip_term_status"]
        }
      )
      event
    end
  end
end
