require "rails_helper"

RSpec.describe Carrier do
  it "handles image processing" do
    carrier = create(:carrier, :with_logo)

    carrier.logo.variant(resize_to_limit: [100, 100]).processed

    expect(ActiveStorage::VariantRecord.count).to eq(1)
  end
end
