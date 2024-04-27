require "rails_helper"

RSpec.describe PhoneNumberTypeValidator do
  it "validates a phone number type" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
      attribute :type

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :type, phone_number_type: true
    end


    expect(validatable_klass.new(number: "1294", type: "foobar").valid?).to eq(false)

    expect(validatable_klass.new(number: "1294", type: "short_code").valid?).to eq(true)
    expect(validatable_klass.new(number: "1294", type: "mobile").valid?).to eq(false)
    expect(validatable_klass.new(number: "1294", type: "local").valid?).to eq(false)
    expect(validatable_klass.new(number: "1294", type: "toll_free").valid?).to eq(false)

    expect(validatable_klass.new(number: "12513095542", type: "short_code").valid?).to eq(false)
    expect(validatable_klass.new(number: "12513095542", type: "mobile").valid?).to eq(true)
    expect(validatable_klass.new(number: "12513095542", type: "local").valid?).to eq(true)
    expect(validatable_klass.new(number: "12513095542", type: "toll_free").valid?).to eq(true)
  end
end
