class DestroyTariffSchedule < ApplicationWorkflow
  attr_reader :tariff_schedule, :client

  def initialize(tariff_schedule, **options)
    super()
    @tariff_schedule = tariff_schedule
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      tariff_schedule.destroy
      client.destroy_tariff_schedule(tariff_schedule) if tariff_schedule.destroyed?
      tariff_schedule.destroyed?
    end
  end
end
