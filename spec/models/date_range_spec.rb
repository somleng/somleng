require "rails_helper"

RSpec.describe DateRange do
  describe "#valid?" do
    it "validates the date range" do
      expect(DateRange.new(from_date: nil, to_date: nil).valid?).to be(false)
      expect(DateRange.new(from_date: nil, to_date: Date.today).valid?).to be(true)
      expect(DateRange.new(from_date: Time.current, to_date: nil).valid?).to be(true)
      expect(DateRange.new(from_date: 1.day.ago, to_date: Date.today).valid?).to be(true)
      expect(DateRange.new(from_date: Time.current, to_date: 1.day.ago).valid?).to be(false)
    end
  end

  describe "#to_range" do
    it "returns a range" do
      from_date = 1.day.ago
      to_date = Time.current

      expect(DateRange.new(from_date: nil, to_date:).to_range).to eq(
        Range.new(nil, to_date + 1.day)
      )
      expect(DateRange.new(from_date:, to_date: nil).to_range).to eq(
        Range.new(from_date, nil)
      )
      expect(DateRange.new(from_date:, to_date:).to_range).to eq(
        Range.new(from_date, to_date + 1.day)
      )
    end
  end
end
