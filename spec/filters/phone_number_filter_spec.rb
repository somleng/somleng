require "rails_helper"

RSpec.describe PhoneNumberFilter do
  it "filters by assigned" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    assigned_phone_number = create(:phone_number, carrier:)
    unassigned_phone_number = create(:phone_number, carrier:)
    create(:phone_number_plan, account:, phone_number: assigned_phone_number)

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
