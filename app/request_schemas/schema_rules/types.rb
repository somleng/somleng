module SchemaRules
  module Types
    include Dry.Types()

    class PhoneNumber
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
    end

    Number = String.constructor do |string|
      string.to_s.gsub(/\D/, "")
    end

    UppercaseString = String.constructor do |string|
      string.to_s.upcase
    end

    SenderID = String.constructor do |value|
      PhoneNumber.new(number: value).number&.alphanumeric? ? value.to_s : Number.call(value)
    end
  end
end
