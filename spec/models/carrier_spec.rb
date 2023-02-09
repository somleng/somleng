require "rails_helper"

RSpec.describe Carrier do
  it "handles image processing" do
    carrier = create(:carrier, :with_logo)

    expect(carrier.logo.variant(resize_to_limit: [100, 100]).processed.url).to be_present
  end
end
