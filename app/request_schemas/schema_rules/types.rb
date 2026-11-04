module SchemaRules
  module Types
    include Dry.Types()

    def self.alphanumeric_sender_id?(value)
      AlphanumericSenderIDFormatValidator::ALPHA_ONLY_REGEXP.match?(value.to_s)
    end

    Number = String.constructor do |string|
      string.gsub(/\D/, "") if string.present?
    end

    UppercaseString = String.constructor do |string|
      string.upcase if string.present?
    end

    SenderID = String.constructor do |value|
      Types.alphanumeric_sender_id?(value) ? value.strip : Number.call(value)
    end
  end
end
