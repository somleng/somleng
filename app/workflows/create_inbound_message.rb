class CreateInboundMessage < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    super()
    @params = params
  end

  def call
    return if drop_message?

    message = nil
    ApplicationRecord.transaction do
      message = Message.create!(params)
      create_interaction(message)

      CreateMessageCharge.call(message)
    end

    ExecuteWorkflowJob.perform_later(
      "ExecuteMessagingTwiML",
      message:,
      url: message.sms_url,
      http_method: message.sms_method
    )
  rescue CreateMessageCharge::Error => e
    CreateErrorLog.call(
      type: :inbound_message,
      carrier: e.record.carrier,
      account: e.record.account,
      error_message: e.record.error_message
    )
  end

  private

  def drop_message?
    return false if params[:messaging_service].blank?

    params.fetch(:messaging_service).inbound_message_behavior.drop?
  end

  def create_interaction(message)
    Interaction.create_or_find_by!(message:) do |interaction|
      interaction.attributes = {
        interactable_type: "Message",
        carrier: message.carrier,
        account: message.account,
        beneficiary_country_code: message.beneficiary_country_code,
        beneficiary_fingerprint: message.beneficiary_fingerprint
      }
    end
  end
end
