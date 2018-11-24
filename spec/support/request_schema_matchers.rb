module RequestSchemaMatchers
  extend RSpec::Matchers::DSL

  matcher :have_valid_field do |*path|
    options = path.extract_options!
    match do |actual|
      actual.errors.dig(*path).blank?
    end

    match_when_negated do |actual|
      errors = actual.errors.dig(*path)
      break false if errors.blank?
      break true if options[:error_message].blank?

      errors.any? { |err| err.match?(options.fetch(:error_message)) }
    end
  end
end

RSpec.configure do |config|
  config.include RequestSchemaMatchers, type: :request_schema
end
