class RedactMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    super()
    @message = message
  end

  def call
    message.update!(body: "")
  end
end
