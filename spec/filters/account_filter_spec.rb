require "rails_helper"

RSpec.describe AccountFilter do
  it "Filters by metadata" do
    account = create(
      :account,
      metadata: {
        foo: "bar"
      }
    )
    _other_account = create(:account)
    filter = AccountFilter.new(
      resources_scope: Account,
      input_params: {
        filter: {
          metadata: {
            key: "foo",
            value: "bar"
          }
        }
      }
    )

    result = filter.apply

    expect(result).to eq([account])
  end

  it "Filters by nested metadata" do
    account = create(
      :account,
      metadata: {
        foo: {
          bar: "baz"
        }
      }
    )
    _other_account = create(:account)
    filter = AccountFilter.new(
      resources_scope: Account,
      input_params: {
        filter: {
          metadata: {
            key: "foo.bar",
            value: "baz"
          }
        }
      }
    )

    result = filter.apply

    expect(result).to eq([account])
  end

  it "filters by type" do
    customer_managed_account = create(:account)
    create(:account_membership, account: customer_managed_account)
    carrier_managed_account = create(:account, :carrier_managed)
    filter = AccountFilter.new(
      resources_scope: Account,
      input_params: {
        filter: {
          type: "customer_managed"
        }
      }
    )

    result = filter.apply

    expect(result).to eq([customer_managed_account])

    filter = AccountFilter.new(
      resources_scope: Account,
      input_params: {
        filter: {
          type: "carrier_managed"
        }
      }
    )

    result = filter.apply

    expect(result).to eq([carrier_managed_account])
  end
end
