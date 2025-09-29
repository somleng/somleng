class UpdateCallServiceCapacity < ApplicationWorkflow
  attr_reader :region, :capacity, :call_service_capacity

  def initialize(params, **options)
    super(**options)
    @region = params.fetch(:region)
    @capacity = params.fetch(:capacity)
    @call_service_capacity = options.fetch(:call_service_capacity) { CallServiceCapacity }
  end

  def call
    call_service_capacity.set_for(region, capacity:)
  end
end
