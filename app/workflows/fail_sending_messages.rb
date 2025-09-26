class FailSendingMessages < ApplicationWorkflow
  def call
    Message.sending.where(sending_at: ..5.minutes.ago).find_each do |message|
      UpdateMessageStatus.new(message).call { message.mark_as_failed! }
    end
  end
end
