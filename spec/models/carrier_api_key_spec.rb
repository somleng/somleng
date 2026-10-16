require "rails_helper"

RSpec.describe CarrierAPIKey do
  it "sets defaults" do
    oauth_application = create(:oauth_application, :carrier)
    api_key = CarrierAPIKey.new(oauth_application:)

    api_key.save!

    expect(api_key).to have_attributes(
      persisted?: true,
      scopes: oauth_application.scopes
    )
  end
end
