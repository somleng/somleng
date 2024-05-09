class UpdateLiveCallJob < ApplicationJob
  self.queue_adapter = :async

  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    response = if phone_call.user_terminated?
      call_service_client.end_call(
        id: phone_call.external_id,
        host: phone_call.call_service_host
      )
    else
      call_service_client.update_call(
        id: phone_call.external_id,
        host: phone_call.call_service_host,
        **build_update_params(phone_call)
      )
    end

    return if response.success?

    raise RetryJob, "Response body: #{response.body}"
  end

  private

  def build_update_params(phone_call)
    result = {}
    if phone_call.voice_url.present?
      result[:voice_url] = phone_call.voice_url
      result[:voice_method] = phone_call.voice_method
    else
      result[:twiml] = phone_call.twiml
    end
    result
  end
end
