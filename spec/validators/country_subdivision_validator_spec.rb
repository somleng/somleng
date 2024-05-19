require "rails_helper"

RSpec.describe CountrySubdivisionValidator do
  it "validates a country subdivision" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :region
      attribute :country_code

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :region, country_subdivision: { country_code: ->(record) { record.country_code } }
    end

    expect(validatable_klass.new(region: "AK", country_code: "US").valid?).to eq(true)
    expect(validatable_klass.new(region: "ak", country_code: "US").valid?).to eq(true)
    expect(validatable_klass.new(region: "AK").valid?).to eq(false)
    expect(validatable_klass.new(region: "AB", country_code: "CA").valid?).to eq(true)
    expect(validatable_klass.new(region: "AK", country_code: "CA").valid?).to eq(false)
  end
end
