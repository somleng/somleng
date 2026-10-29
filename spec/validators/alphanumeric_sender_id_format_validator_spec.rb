require "rails_helper"

RSpec.describe AlphanumericSenderIDFormatValidator do
  it "validates an alphanumeric sender id" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :alphanumeric_sender_id

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :alphanumeric_sender_id,
                alphanumeric_sender_id_format: true
    end

    expect(validatable_klass.new.valid?).to be(false)
    expect(validatable_klass.new(alphanumeric_sender_id: "12345").valid?).to be(false)
    expect(validatable_klass.new(alphanumeric_sender_id: "A" * 12).valid?).to be(false)
    expect(validatable_klass.new(alphanumeric_sender_id: "A" * 2).valid?).to be(false)
    expect(validatable_klass.new(alphanumeric_sender_id: "+1").valid?).to be(false)
    expect(validatable_klass.new(alphanumeric_sender_id: "AAA").valid?).to be(true)
    expect(validatable_klass.new(alphanumeric_sender_id: "A 9+-_&A.B").valid?).to be(true)
  end

  it "allows numerics" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :alphanumeric_sender_id

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :alphanumeric_sender_id,
                alphanumeric_sender_id_format: {
                  allow_numeric: true,
                  allow_blank: true
                }
    end

    expect(validatable_klass.new.valid?).to be(true)
    expect(validatable_klass.new(alphanumeric_sender_id: "123423456782").valid?).to be(true)
    expect(validatable_klass.new(alphanumeric_sender_id: "+123423456782").valid?).to be(false)
  end
end
