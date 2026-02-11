class CreatePhoneCall < ApplicationWorkflow
  attr_reader :params

  def initialize(params = {})
    super()
    @params = params
  end

  def call
    phone_call = PhoneCall.create!(params)
    ScheduleOutboundCall.call(phone_call)
    phone_call
  end
end
