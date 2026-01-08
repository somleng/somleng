class UpdateTariffScheduleForm < UpdateRatingEngineResource
  def call
    super do
      client.upsert_tariff_schedule(resource.object)
    end
  end
end
