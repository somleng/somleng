class UpdateSwitchCapacity < ApplicationWorkflow
  attr_reader :region, :capacity, :switch_capacity, :log_key

  def initialize(params, **options)
    super(**options)
    @region = params.fetch(:region)
    @capacity = params.fetch(:capacity)
    @switch_capacity = options.fetch(:switch_capacity) { SwitchCapacity }
    @log_key = options.fetch(:log_key) { AppSettings.fetch(:switch_capacity_log_key) }
  end

  def call
    switch_capacity.set_for(region, capacity:)
    log_capacity(capacity)
  end

  private

  def log_capacity(capacity)
    logger.info(JSON.generate(log_key => capacity))
  end
end
