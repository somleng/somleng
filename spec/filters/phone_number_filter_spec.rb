require "rails_helper"

RSpec.describe PhoneNumberFilter do
  it "filters by utilized" do
    utilized_phone_number = create(:phone_number, :utilized)
    unutilized_phone_number = create(:phone_number)

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { utilized: true } }
      ).apply
    ).to match_array([ utilized_phone_number ])

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { utilized: false } }
      ).apply
    ).to match_array([ unutilized_phone_number ])
  end

  it "filters by assigned" do
    assigned_phone_number = create(:phone_number, :assigned_to_account)
    unassigned_phone_number = create(:phone_number)

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { assigned: true } }
      ).apply
    ).to match_array([ assigned_phone_number ])

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { assigned: false } }
      ).apply
    ).to match_array([ unassigned_phone_number ])
  end

  it "filters by number" do
    filtered_phone_number = create(:phone_number, number: "1294")
    create(:phone_number, number: "1279")

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { number: "1294" } }
      ).apply
    ).to match_array([ filtered_phone_number ])
  end
end
