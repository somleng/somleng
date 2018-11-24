class PhoneCallRequestSchema < ApplicationRequestSchema
  FROM_REGEX = /\A\+?\d+\z/.freeze
  HTTP_METHODS = %w[GET POST].freeze

  define_schema do
    configure do
      def phone_number?(value)
        PhoneNumberValidator.new(phone_number: value).valid?
      end

      def url?(value)
        UrlValidator.new(url: value).valid?
      end

      def http_method?(value)
        HTTP_METHODS.include?(value)
      end
    end

    required(:To, :string).filled(:str?, phone_number?: true)
    required(:From, :string).filled(:str?, format?: FROM_REGEX)
    required(:Url, :string).filled(:str?, url?: true)
    optional(:Method, ApplicationRequestSchema::Types::HTTPMethod).filled(:str?, http_method?: true)
    optional(:StatusCallback, :string).filled(:str?, url?: true)
    optional(:StatusCallbackMethod, ApplicationRequestSchema::Types::HTTPMethod).filled(:str?, http_method?: true)
  end

  class PhoneNumberValidator
    include ActiveModel::Model

    attr_accessor :phone_number

    validates :phone_number, phony_plausible: true
  end

  class UrlValidator
    include ActiveModel::Model

    attr_accessor :url

    validates :url, url: { no_local: true, allow_nil: true }
  end
end
