module SchemaRules
  module Types
    include Dry.Types()

    class PhoneNumber
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new

      delegate :alphanumeric?, to: :number
    end

    Number = String.constructor do |string|
      string.gsub(/\D/, "") if string.present?
    end

    UppercaseString = String.constructor do |string|
      string.upcase if string.present?
    end

    SenderID = String.constructor do |value|
      PhoneNumber.new(number: value).alphanumeric? ? value : Number.call(value)
    end
  end
end
