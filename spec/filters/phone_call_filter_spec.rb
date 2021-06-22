require "rails_helper"

RSpec.describe PhoneCallFilter do
  it "Filters by account" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    phone_call = create(:phone_call, account: account)
    _other_phone_call = create(:phone_call)
    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {},
      scoped_to: { account_id: account.id }
    )

    result = filter.apply

    expect(result).to eq([phone_call])
  end

  it "Filters by carrier" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    phone_call = create(:phone_call, account: account)
    _other_phone_call = create(:phone_call)
    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {},
      scoped_to: { carrier_id: carrier.id }
    )

    result = filter.apply

    expect(result).to eq([phone_call])
  end
end
