require "rails_helper"

RSpec.describe AccountPolicy, type: :policy do
  it "handles access for destroying accounts" do
    carrier = create(:carrier)
    carrier_user = build_stubbed(:user, :carrier, carrier:)
    customer_user = build_stubbed(:user, :customer, carrier:)

    account = create(:account, carrier:)
    account_with_phone_calls = create(:account, carrier:)
    account_with_messages = create(:account, carrier:)
    create(:phone_call, account: account_with_phone_calls)
    create(:message, account: account_with_messages)
    customer_managed_account = create(:account, :customer_managed, carrier:)

    expect(AccountPolicy.new(carrier_user, account)).to be_destroy
    expect(AccountPolicy.new(customer_user, account)).not_to be_destroy
    expect(AccountPolicy.new(carrier_user, account_with_phone_calls)).not_to be_destroy
    expect(AccountPolicy.new(carrier_user, account_with_messages)).not_to be_destroy
    expect(AccountPolicy.new(carrier_user, customer_managed_account)).not_to be_destroy
  end

  it "handles access for reading accounts" do
    expect(AccountPolicy.new(build_stubbed(:user, :carrier))).to be_read
    expect(AccountPolicy.new(build_stubbed(:user, :customer))).not_to be_read
  end

  it "handles access for managing accounts" do
    expect(AccountPolicy.new(build_stubbed(:user, :carrier, :admin))).to be_manage
    expect(AccountPolicy.new(build_stubbed(:user, :carrier, :member))).not_to be_manage
    expect(AccountPolicy.new(build_stubbed(:user, :customer))).not_to be_manage
  end

  it "handles access for showing an auth token" do
    user = build_stubbed(:user, :carrier)

    expect(AccountPolicy.new(user, build_stubbed(:account, :carrier_managed))).to be_show_auth_token
    expect(AccountPolicy.new(user, build_stubbed(:account, :customer_managed))).not_to be_show_auth_token
  end
end
