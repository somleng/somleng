class RatingEngineClient
  class APIError < StandardError; end

  def upsert_destination_group(destination_group)
    client.set_tp_destination(
      tp_id: destination_group.carrier_id,
      id: destination_group.id,
      prefixes: destination_group.prefixes.pluck(:prefix)
    )
  end

  def upsert_tariff_schedule(tariff_schedule)
    destination_tariffs = tariff_schedule.destination_tariffs.includes(:tariff)

    destination_tariffs.each do |destination_tariff|
      tariff = destination_tariff.tariff
      client.set_tp_rate(
        tp_id: tariff_schedule.carrier_id,
        id: tariff.id,
        rate_slots: [
          { rate: tariff.rate.to_f, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
    end

    client.set_tp_destination_rate(
      tp_id: tariff_schedule.carrier_id,
      id: tariff_schedule.id,
      destination_rates: destination_tariffs.map do |destination_tariff|
        {
          rounding_decimals: 4,
          rate_id: destination_tariff.tariff_id,
          destination_id: destination_tariff.destination_group_id,
          rounding_method: "*up"
        }
      end
    )
  end

  def destroy_tariff_schedule(tariff_schedule)
    client.remove_tp_destination_rate(
      tp_id: tariff_schedule.carrier_id,
      id: tariff_schedule.id,
    )
  end

  private

  def make_request
    yield
  rescue CGRateS::APIError => e
    raise APIError.new(e.message)
  end

  def client
    @client ||= CGRateS::Client.new
  end
end
