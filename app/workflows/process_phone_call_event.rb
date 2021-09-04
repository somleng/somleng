class ProcessPhoneCallEvent < ApplicationWorkflow
  attr_reader :type, :external_phone_call_id, :params

  def initialize(options)
    @type = options.fetch(:type)
    @external_phone_call_id = options.fetch(:external_phone_call_id)
    @params = options.fetch(:params)
  end

  def call
    phone_call = PhoneCall.find_by!(external_id: external_phone_call_id)

    ApplicationRecord.transaction do
      event = PhoneCallEvent.create!(permitted_params)
      UpdatePhoneCallStatus.call(
        event.phone_call,
        event_type: event.type,
        answer_epoch: event.params["answer_epoch"],
        sip_term_status: event.params["sip_term_status"]
      )
    end
  end

  private


end
