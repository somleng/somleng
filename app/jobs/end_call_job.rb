class EndCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    return if phone_call.external_id.blank?

    response = call_service_client.end_call(phone_call.external_id)

    raise RetryJob, "Response body: #{response.body}" unless response.success?
  end
end
