class NotifyWebhookEndpoint < ApplicationWorkflow
  MAX_ATTEMPTS = 9
  RETRY_PERIOD = 5.days

  attr_accessor :webhook_endpoint, :event

  def initialize(webhook_endpoint, event)
    self.webhook_endpoint = webhook_endpoint
    self.event = event
  end

  def call
    response = notify_webhook_endpoint

    webhook_request_log = WebhookRequestLog.create!(
      event:,
      carrier: event.carrier,
      url: webhook_endpoint.url,
      webhook_endpoint:,
      http_status_code: response.status,
      payload:,
      failed: !response.success?
    )

    retry_request_webhook_endpoint if !response.success? && retry_webhook_request?

    webhook_request_log
  end

  private

  def notify_webhook_endpoint
    http_client.post(webhook_endpoint.url, payload.to_json)
  rescue Faraday::ConnectionFailed
    ConnectionError.new
  end

  def retry_webhook_request?
    failed_attempts_count < MAX_ATTEMPTS
  end

  def payload
    @payload ||= CarrierAPI::EventSerializer.new(event).as_json
  end

  def retry_request_webhook_endpoint
    retry_at = Utils.exponential_backoff_delay(
      max_retry_period: RETRY_PERIOD,
      number_of_attempts: failed_attempts_count,
      max_attempts: MAX_ATTEMPTS
    ).seconds.from_now

    ScheduledJob.perform_later(
      ExecuteWorkflowJob.to_s,
      self.class.to_s,
      webhook_endpoint,
      event,
      wait_until: retry_at.to_f
    )
  end

  def http_client
    @http_client ||= Faraday.new do |conn|
      conn.headers["Content-Type"] = "application/json"
      conn.headers["Authorization"] = "Bearer #{generate_signature}"
      conn.headers["User-Agent"] = "Somleng/1.0"

      conn.adapter Faraday.default_adapter
    end
  end

  def generate_signature
    JWT.encode(
      {
        iss: "Somleng",
        exp: 5.minutes.from_now.to_i
      },
      webhook_endpoint.signing_secret,
      "HS256"
    )
  end

  def failed_attempts_count
    @failed_attempts_count ||= event.webhook_request_logs.where(webhook_endpoint:).failed.count
  end

  class ConnectionError
    # Origin Is Unreachable (Cloudfare)
    # https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#Cloudflare
    HTTP_STATUS_CODE = "523".freeze

    def success?
      false
    end

    def status
      HTTP_STATUS_CODE
    end
  end
end
