require "rails_helper"

RSpec.describe DestroyTariffPlan do
  it "destroys a tariff plan" do
    tariff_plan = create(:tariff_plan)
    client = instance_spy(RatingEngineClient)

    result = DestroyTariffPlan.call(tariff_plan, client:)

    expect(result).to be_truthy
    expect(tariff_plan).to have_attributes(
      persisted?: false
    )
    expect(client).to have_received(:destroy_tariff_plan).with(tariff_plan)
  end

  it "handles validation errors" do
    tariff_plan = create(:tariff_plan)
    create(:tariff_plan_subscription, plan: tariff_plan, carrier: tariff_plan.carrier)
    client = instance_spy(RatingEngineClient)

    result = DestroyTariffPlan.call(tariff_plan, client:)

    expect(result).to be_falsey
    expect(tariff_plan).to have_attributes(
      persisted?: true,
      subscriptions: contain_exactly(
        have_attributes(
          persisted?: true
        )
      )
    )
    expect(client).not_to have_received(:destroy_tariff_plan)
  end
end
