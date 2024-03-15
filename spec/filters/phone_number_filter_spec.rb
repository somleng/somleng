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

  it "filters by configured" do
    configured_phone_number = create(:phone_number, :configured)
    unconfigured_phone_number = create(:phone_number)

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { configured: true } }
      ).apply
    ).to match_array([ configured_phone_number ])

    expect(
      PhoneNumberFilter.new(
        resources_scope: PhoneNumber,
        input_params: { filter: { configured: false } }
      ).apply
    ).to match_array([ unconfigured_phone_number ])
  end
end
