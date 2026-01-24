require "rails_helper"

RSpec.describe DestroyAccount do
  it "destroys an account" do
    account = create(:account)
    client = instance_spy(RatingEngineClient)

    DestroyAccount.call(account, client:)

    expect(account).to have_attributes(
      persisted?: false
    )
    expect(client).to have_received(:destroy_account).with(account)
  end

  it "handles validation errors" do
    account = create(:account, :customer_managed, :with_access_token)
    client = instance_spy(RatingEngineClient)

    DestroyAccount.call(account, client:)

    expect(account).to have_attributes(
      persisted?: true,
      access_token: have_attributes(
        persisted?: true
      )
    )
    expect(client).not_to have_received(:destroy_account)
  end
end
