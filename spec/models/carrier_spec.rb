require "rails_helper"

RSpec.describe Carrier do
  it "handles image processing" do
    carrier = create(:carrier, :with_logo)

    carrier.logo.variant(resize_to_limit: [100, 100]).processed

    expect(carrier.logo.variant_records).to be_present
  end
end
