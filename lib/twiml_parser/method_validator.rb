module TwiMLParser
  class MethodValidator
    VALID_METHODS = %w[GET POST].freeze

    def valid?(method)
      return true if method.blank?

      method.in?(VALID_METHODS)
    end
  end
end
