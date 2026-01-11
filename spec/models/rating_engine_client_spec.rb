require "rails_helper"

RSpec.describe RatingEngineClient do
  describe "#upsert_destination_group" do
    it "sends a request to upsert a destination group" do
      destination_group = create(:destination_group, prefixes: [ "855" ])
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_destination_group(destination_group)

      expect(client).to have_received(:set_tp_destination).with(
        tp_id: destination_group.carrier_id,
        id: destination_group.id,
        prefixes: [ "855" ]
      )
    end
  end

  describe "#upsert_tariff_schedule" do
    it "sends a request to upsert a tariff schedule" do
      carrier = create(:carrier, billing_currency: "USD")
      tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:)
      tariffs = [
        create(:tariff, :call, carrier:, rate_cents: InfinitePrecisionMoney.from_amount(0.005, "USD").cents),
        create(:tariff, :call, carrier:, rate_cents: InfinitePrecisionMoney.from_amount(0.001, "USD").cents)
      ]
      destination_tariffs = [
        create(:destination_tariff, schedule: tariff_schedule, tariff: tariffs[0]),
        create(:destination_tariff, schedule: tariff_schedule, tariff: tariffs[1])
      ]
      client = instance_spy(CGRateS::Client)
      rating_engine_client = RatingEngineClient.new(client:)

      rating_engine_client.upsert_tariff_schedule(tariff_schedule)

      expect(client).to have_received(:set_tp_rate).with(
        tp_id: carrier.id,
        id: tariffs[0].id,
        rate_slots: [
          { rate: 0.005, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
      expect(client).to have_received(:set_tp_rate).with(
        tp_id: carrier.id,
        id: tariffs[1].id,
        rate_slots: [
          { rate: 0.001, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
      expect(client).to have_received(:set_tp_destination_rate).with(
        tp_id: carrier.id,
        id: tariff_schedule.id,
        destination_rates: [
          {
            rounding_decimals: 4,
            rounding_method: "*up",
            rate_id: tariffs[0].id,
            destination_id: destination_tariffs[0].destination_group_id
          },
          hash_including(
            rate_id: tariffs[1].id,
            destination_id: destination_tariffs[1].destination_group_id,
          )
        ]
      )
    end
  end
end
