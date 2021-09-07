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
end
