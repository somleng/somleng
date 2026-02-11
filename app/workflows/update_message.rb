class UpdateMessage < ApplicationWorkflow
  attr_reader :message, :params

  def initialize(message, params = {})
    super()
    @message = message
    @params = params
  end

  def call
    RedactMessage.call(message) if redact?
    UpdateMessageStatus.new(message).call { message.cancel! } if cancel?
    message
  end

  private

  def redact?
    params[:redact].present?
  end

  def cancel?
    params[:cancel].present?
  end
end
