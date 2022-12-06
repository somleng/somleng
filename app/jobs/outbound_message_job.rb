class OutboundMessageJob < ApplicationJob
  def perform(message)
    SendOutboundMessage.call(message)
  end
end
