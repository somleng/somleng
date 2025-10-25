require "rails_helper"

RSpec.describe TariffScheduleForm do
  it "validates the name" do
    form = TariffScheduleForm.new

    form.valid?

    expect(form.errors[:name]).to be_present
  end

  it "validates the category" do

  end

  describe "#save" do
  end
end
