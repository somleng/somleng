require "rails_helper"

RSpec.describe DateRange do
  describe "#valid?" do
    it "validates the date range" do
      expect(DateRange.new(from_date: nil, to_date: nil).valid?).to be(false)
      expect(DateRange.new(from_date: nil, to_date: Date.today).valid?).to be(true)
      expect(DateRange.new(from_date: Date.today, to_date: nil).valid?).to be(true)
      expect(DateRange.new(from_date: Date.yesterday, to_date: Date.today).valid?).to be(true)
      expect(DateRange.new(from_date: Date.today, to_date: Date.yesterday).valid?).to be(false)
    end
  end

  describe "#to_range" do
    it "returns a range" do
      expect(DateRange.new(from_date: nil, to_date: Date.today).to_range).to eq(
        Range.new(nil, Date.today.end_of_day)
      )
      expect(DateRange.new(from_date: Date.today, to_date: nil).to_range).to eq(
        Range.new(Date.today.beginning_of_day, nil)
      )
      expect(DateRange.new(from_date: Date.yesterday, to_date: Date.today).to_range).to eq(
        Range.new(Date.yesterday.beginning_of_day, Date.today.end_of_day)
      )
    end
  end
end
