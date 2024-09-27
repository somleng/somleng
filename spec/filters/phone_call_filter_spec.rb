require "rails_helper"

RSpec.describe PhoneCallFilter do
  it "filters by account" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_call = create(:phone_call, account:)
    _other_phone_call = create(:phone_call)
    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {},
      scoped_to: { account_id: account.id }
    )

    result = filter.apply

    expect(result).to eq([ phone_call ])
  end

  it "filters by carrier" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_call = create(:phone_call, account:)
    _other_phone_call = create(:phone_call)
    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {},
      scoped_to: { carrier_id: carrier.id }
    )

    result = filter.apply

    expect(result).to eq([ phone_call ])
  end

  it "filters by status" do
    queued_phone_call = create(:phone_call, :queued)
    initiated_phone_call = create(:phone_call, :initiated)
    _failed_phone_call = create(:phone_call, :failed)
    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {
        filter: {
          status: "queued"
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(queued_phone_call, initiated_phone_call)
  end

  it "filters by to" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    incoming_phone_number = create(:incoming_phone_number, account:)
    phone_call = create(:phone_call, :inbound, incoming_phone_number:, account:, carrier:, to: incoming_phone_number.number)
    _other_phone_call = create(:phone_call)

    filter = PhoneCallFilter.new(
      resources_scope: PhoneCall,
      input_params: {
        filter: {
          to: phone_call.to.value
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(phone_call)
  end
end
