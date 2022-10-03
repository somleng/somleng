require "rails_helper"

RSpec.describe NotifyWebhookEndpoint do
  it "re-enqueues the job if it receives a non 2xx response" do
    event = create(:event)
    webhook_endpoint = create(:webhook_endpoint)
    stub_request(:post, webhook_endpoint.url).to_return(status: 500)

    _first_log_for_failed_request = create(
      :webhook_request_log,
      :failed,
      event:,
      webhook_endpoint:
    )

    webhook_request_log = NotifyWebhookEndpoint.call(webhook_endpoint, event)

    expect(webhook_request_log.failed?).to eq(true)
    expect(
      ScheduledJob
    ).to have_been_enqueued.with(
      ExecuteWorkflowJob.to_s,
      NotifyWebhookEndpoint.to_s,
      webhook_endpoint,
      event,
      wait_until: be_present
    )
  end

  it "re-enqueues the job if the connection failed" do
    event = create(:event)
    webhook_endpoint = create(:webhook_endpoint)
    stub_request(:post, webhook_endpoint.url).to_raise(Faraday::ConnectionFailed)

    webhook_request_log = NotifyWebhookEndpoint.call(webhook_endpoint, event)

    expect(webhook_request_log.failed?).to eq(true)
    expect(webhook_request_log.http_status_code).to eq("523")
  end

  it "does not re-enqueue the job when response is successful" do
    event = create(:event)
    webhook_endpoint = create(:webhook_endpoint)
    stub_request(:post, webhook_endpoint.url).to_return(status: 201)

    webhook_request_log = NotifyWebhookEndpoint.call(webhook_endpoint, event)

    expect(webhook_request_log.failed?).to eq(false)
    expect(ScheduledJob).not_to have_been_enqueued
  end

  it "does not re-enqueue the job when it reaches max attempts" do
    stub_const("NotifyWebhookEndpoint::MAX_ATTEMPTS", 1)
    event = create(:event)
    webhook_endpoint = create(:webhook_endpoint)
    stub_request(:post, webhook_endpoint.url).to_return(status: 500)

    NotifyWebhookEndpoint.call(webhook_endpoint, event)

    expect(ScheduledJob).not_to have_been_enqueued
  end

  it "makes a request with a valid signature" do
    event = create(:event)
    webhook_endpoint = create(:webhook_endpoint, signing_secret: "secret")
    stub_request(:post, webhook_endpoint.url)

    NotifyWebhookEndpoint.call(webhook_endpoint, event)

    expect(WebMock).to have_requested(:post, webhook_endpoint.url).with { |request|
      expect(request.body).to match_jsonapi_resource_schema("carrier_api/event")
      expect(request.headers["User-Agent"]).to eq("Somleng/1.0")
      expect {
        JWT.decode(
          request.headers["Authorization"].sub("Bearer ", ""),
          "secret",
          true,
          algorithm: "HS256",
          verify_iss: true,
          iss: "Somleng"
        )
      }.not_to raise_error
    }
  end
end
