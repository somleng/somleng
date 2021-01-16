module RequestSchemaMatchers
  extend RSpec::Matchers::DSL

  module Helpers
    def valid?(actual, *path)
      actual.errors.none? { |e| e.path == path }
    end

    def invalid?(actual, *path)
      options = path.extract_options!
      errors = actual.errors.to_h.dig(*path)

      return false if errors.blank?

      error_expectations = {
        text: options[:error_message],
        code: options[:error_code],
        detail: options[:error_detail]
      }.compact

      return true if error_expectations.blank?

      errors.any? do |actual_error|
        if actual_error.is_a?(Hash)
          error_expectations.all? { |key, value| actual_error[key] == value }
        else
          actual_error.match?(error_expectations.fetch(:text))
        end
      end
    end
  end

  matcher :have_valid_field do |*path|
    include Helpers

    match { |actual| valid?(actual, *path) }
    match_when_negated { |actual| invalid?(actual, *path) }

    failure_message do |actual|
      "expected: schema not to have errors on #{path.inspect}\ngot: #{actual.errors.to_h}"
    end
  end
end

RSpec.configure do |config|
  config.include RequestSchemaMatchers, type: :request_schema
end
