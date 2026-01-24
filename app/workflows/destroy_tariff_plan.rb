class DestroyTariffPlan < ApplicationWorkflow
  attr_reader :tariff_plan, :client

  def initialize(tariff_plan, **options)
    super()
    @tariff_plan = tariff_plan
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      tariff_plan.destroy
      client.destroy_tariff_plan(tariff_plan) if tariff_plan.destroyed?
      tariff_plan.destroyed?
    end
  end
end
