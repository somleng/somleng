class OutboundCallJob < ApplicationJob
  def perform(phone_call)
    InitiateOutboundCall.call(phone_call)
  end
end
