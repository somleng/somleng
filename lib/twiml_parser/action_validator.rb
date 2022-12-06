module TwiMLParser
  class ActionValidator
    URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

    def valid?(action, options = {})
      return false if action.blank? && options[:allow_blank].blank?
      return true if action.blank?
      return true if action.starts_with?("/")

      URL_FORMAT.match?(action)
    end
  end
end
