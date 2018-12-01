class AbstractPhoneCallRequestSchema < ApplicationRequestSchema
  class_attribute :phone_number_regex, default: /\A\+?\d+\z/.freeze
  class_attribute :http_methods, default: %w[GET POST].freeze

  def phone_number?(value)
    PhoneNumberValidator.new(phone_number: value).valid?
  end

  def url?(value)
    UrlValidator.new(url: value).valid?
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
