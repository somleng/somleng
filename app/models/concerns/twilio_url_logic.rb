module TwilioUrlLogic
  extend ActiveSupport::Concern

  DEFAULT_URL_METHOD = "POST".freeze
  ALLOWED_URL_METHODS = [DEFAULT_URL_METHOD, "GET"].freeze

  included do
    validates :voice_url, :voice_method, presence: true

    validates :voice_url,
              :status_callback_url,
              url: {
                no_local: true, allow_nil: true
              }

    validates :voice_method,
              :status_callback_method,
              inclusion: {
                in: ALLOWED_URL_METHODS,
                allow_nil: true
              }

    before_validation :set_default_url_methods,
                      :normalize_url_methods,
                      on: :create

    alias_attribute :Url, :voice_url
    alias_attribute :Method, :voice_method
    alias_attribute :StatusCallback, :status_callback_url
    alias_attribute :StatusCallbackMethod, :status_callback_method
  end

  private

  def set_default_url_methods
    self.voice_method ||= DEFAULT_URL_METHOD
  end

  def normalize_url_methods
    self.voice_method.upcase! if voice_method?
    status_callback_method.upcase! if status_callback_method?
  end
end
