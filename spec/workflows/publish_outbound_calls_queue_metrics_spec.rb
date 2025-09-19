require "rails_helper"

RSpec.describe PublishOutboundCallsQueueMetrics do
  it "publishes metrics about the queue" do
    create_list(:phone_call, 3, :queued, region: :hydrogen)
    create_list(:phone_call, 2, :queued, region: :helium)
    create(:phone_call, :completed, region: :hydrogen)
    logger = instance_spy(Rails.logger.class)

    PublishOutboundCallsQueueMetrics.call(logger:)

    expect(logger).to have_received(:info) do |log|
      expect(JSON.parse(log).fetch("outbound_calls_queue_metrics")).to eq(
        "hydrogen" => 3,
        "helium" => 2
      )
    end
  end
end
