class PublishOutboundCallsQueueMetrics < ApplicationWorkflow
  attr_reader :logger

  def initialize(**options)
    super()
    @logger = options.fetch(:logger) { Rails.logger }
  end

  def call
    result = PhoneCall.where(status: :queued).group(:region).count
    logger.info(JSON.generate(outbound_calls_queue_metrics: result))
  end
end
