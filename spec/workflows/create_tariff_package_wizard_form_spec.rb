require "rails_helper"

RSpec.describe CreateTariffPackageWizardForm do
  it "creates a tariff package with associated records" do
    carrier = create(:carrier, billing_currency: "USD")
    form = TariffPackageWizardForm.new(
      carrier:,
      name: "Standard",
      tariffs: [ { enabled: true, rate: 0.01, category: "outbound_calls" } ]
    )
    client = instance_spy(RatingEngineClient)

    CreateTariffPackageWizardForm.call(form, client:)

    expect(form.object).to have_attributes(
      persisted?: true,
      name: "Standard",
      plans: contain_exactly(
        have_attributes(
          category: "outbound_calls",
          schedules: contain_exactly(
            have_attributes(
              category: "outbound_calls",
              destination_tariffs: contain_exactly(
                have_attributes(
                  tariff: have_attributes(
                    rate: InfinitePrecisionMoney.from_amount(0.01, "USD")
                  ),
                  destination_group: have_attributes(
                    catch_all: true
                  )
                )
              )
            )
          )
        )
      )
    )
    expect(client).to have_received(:upsert_destination_group)
    expect(client).to have_received(:upsert_tariff_plan)
    expect(client).to have_received(:upsert_tariff_schedule)
  end
end
