class OutboundMessageJob < ApplicationJob
  def perform(message)
    InitiateOutboundMessage.call(message)
  end
end
