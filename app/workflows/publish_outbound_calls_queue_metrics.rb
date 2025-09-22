class PublishOutboundCallsQueueMetrics < ApplicationWorkflow
  attr_reader :logger, :call_service_capacity, :regions

  def initialize(**options)
    super()
    @logger = options.fetch(:logger) { Rails.logger }
    @call_service_capacity = options.fetch(:call_service_capacity) { CallServiceCapacity }
    @regions = options.fetch(:regions) { SomlengRegion::Region.all }
  end

  def call
    log_queued_calls_per_region
    log_call_service_capacity
  end

  private

  def log_queued_calls_per_region
    calls_per_region = PhoneCall.queued.group(:region).count
    regions.each do |region|
      log_json(outbound_calls_queue_metrics: { queue: region, count: calls_per_region.fetch(region, 0) })
    end
  end

  def log_call_service_capacity
    regions.each do |region|
      log_json(call_service_capacity: { region: region.alias, capacity: call_service_capacity.current_for(region.alias) })
    end
  end

  def log_json(data)
    logger.info(JSON.generate(data))
  end
end
