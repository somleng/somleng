require "rails_helper"

RSpec.describe CountryType do
  it "handles Country types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :country, CountryType.new
    end

    expect(klass.new(country: "KH").country).to be_an_instance_of(ISO3166::Country)
    expect(klass.new(country: ISO3166::Country.new("KH")).country).to be_an_instance_of(ISO3166::Country)
    expect(klass.new(country: nil).country).to eq(nil)
  end
end
