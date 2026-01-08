class UpdateTariffSchedule < ApplicationWorkflow
  def initialize(*, **)
    super(*, action: ->(resource, client) { client.upsert_tariff_schedule(resource) }, **)
  end
end
