class UpdateSwitchCapacity < ApplicationWorkflow
  attr_reader :region, :capacity, :session_limiter

  def initialize(params, **options)
    super()
    @region = params.fetch(:region)
    @capacity = params.fetch(:capacity)
    @session_limiter = options.fetch(:session_limiter) { PhoneCallSessionLimiter.new }
  end

  def call
    session_limiter.set_capacity_for(region, capacity:)
  end
end
