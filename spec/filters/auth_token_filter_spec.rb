require "rails_helper"

RSpec.describe AuthTokenFilter do
  it "filters by revoked" do
    create(:auth_token)
    revoked_auth_token = create(:auth_token, :revoked)
    filter = AuthTokenFilter.new(
      resources_scope: AuthToken,
      input_params: {
        filter: {
          active: false
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(revoked_auth_token)
  end

  it "filters by secondary" do
    account = create(:account)
    secondary_auth_token = create(:auth_token, account:)
    filter = AuthTokenFilter.new(
      resources_scope: AuthToken,
      input_params: {
        filter: {
          primary: false
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(secondary_auth_token)
  end
end
