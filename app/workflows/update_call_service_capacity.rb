class UpdateCallServiceCapacity < ApplicationWorkflow
  attr_reader :region, :capacity, :call_service_capacity, :log_key

  def initialize(params, **options)
    super(**options)
    @region = params.fetch(:region)
    @capacity = params.fetch(:capacity)
    @call_service_capacity = options.fetch(:call_service_capacity) { CallServiceCapacity }
    @log_key = options.fetch(:log_key) { AppSettings.fetch(:call_service_capacity_log_key) }
  end

  def call
    call_service_capacity.set_for(region, capacity:)
    log_capacity(capacity)
  end

  private

  def log_capacity(capacity)
    logger.info(JSON.generate(log_key => capacity))
  end
end
