require "rails_helper"

RSpec.describe PhoneNumberPlanFilter do
  it "filters by status" do
    filtered_plan = create(:phone_number_plan, :active)
    create(:phone_number_plan, :canceled)

    expect(
      PhoneNumberPlanFilter.new(
        resources_scope: PhoneNumberPlan,
        input_params: { filter: { status: "active" } }
      ).apply
    ).to match_array([ filtered_plan ])
  end

  it "filters by number" do
    filtered_plan = create(:phone_number_plan, number: "1294")
    create(:phone_number_plan, number: "1279")

    expect(
      PhoneNumberPlanFilter.new(
        resources_scope: PhoneNumberPlan,
        input_params: { filter: { number: "1294" } }
      ).apply
    ).to match_array([ filtered_plan ])
  end
end
