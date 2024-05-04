class EndCallJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_high_priority_queue_name)

  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    return unless phone_call.was_initiated?

    response = call_service_client.end_call(
      id: phone_call.external_id,
      host: phone_call.call_service_host
    )

    raise RetryJob, "Response body: #{response.body}" unless response.success?
  end
end
