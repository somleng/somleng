require "rails_helper"

RSpec.describe PublishOutboundCallsQueueMetrics do
  it "publishes metrics about the queue" do
    create_list(:phone_call, 3, :queued, region: :hydrogen)
    create_list(:phone_call, 2, :queued, region: :helium)
    create(:phone_call, :completed, region: :hydrogen)
    CallServiceCapacity.set_for("hydrogen", capacity: 5)
    CallServiceCapacity.set_for("helium", capacity: 2)
    logger = instance_spy(Rails.logger.class)

    PublishOutboundCallsQueueMetrics.call(logger:)

    assert_log_json(logger, outbound_calls_queue_metrics: { queue: "hydrogen", count: 3 })
    assert_log_json(logger, outbound_calls_queue_metrics: { queue: "helium", count: 2 })
    assert_log_json(logger, call_service_capacity: { region: "hydrogen", capacity: 5 })
    assert_log_json(logger, call_service_capacity: { region: "helium", capacity: 2 })
  end

  def assert_log_json(logger, data)
    expect(logger).to have_received(:info).with(JSON.generate(data))
  end
end
