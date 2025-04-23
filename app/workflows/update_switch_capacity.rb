class UpdateSwitchCapacity < ApplicationWorkflow
  attr_reader :region, :capacity, :switch_capacity

  def initialize(params, **options)
    super()
    @region = params.fetch(:region)
    @capacity = params.fetch(:capacity)
    @switch_capacity = options.fetch(:switch_capacity) { SwitchCapacity }
  end

  def call
    switch_capacity.set_for(region, capacity:)
  end
end
