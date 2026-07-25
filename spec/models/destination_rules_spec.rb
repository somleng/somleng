require "rails_helper"

RSpec.describe DestinationRules do
  it "validates the destination rules" do
    carrier = create(:carrier)
    account = create(:account, carrier:, allowed_calling_codes: [ "61" ])
    account_with_no_destination_rules = create(:account, carrier:)
    destination_rules = DestinationRules.new

    expect(
      destination_rules.valid?(
        account:,
        destination: "855715100970"
      )
    ).to be(false)
    expect(destination_rules.error_code).to eq(:call_blocked_by_blocked_list)

    expect(
      destination_rules.valid?(
        account:,
        destination: "61434333222"
      )
    ).to be(true)

    expect(
      destination_rules.valid?(
        account: account_with_no_destination_rules,
        destination: "855715100970"
      )
    ).to be(true)
  end
end
