require "rails_helper"

RSpec.describe "Internal API Authorization" do
  it "denies unauthorized access" do
    post(api_internal_phone_calls_path)

    expect(response.code).to eq("401")
  end
end
