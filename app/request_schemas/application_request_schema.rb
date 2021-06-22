class ApplicationRequestSchema < Dry::Validation::Contract
  attr_reader :input_params

  delegate :success?, :errors, :context, to: :result

  module Types
    include Dry.Types()

    PhoneNumber = String.constructor do |string|
      Phony.normalize(string.gsub(/\D/, "")) if string.present?
    end

    UppercaseString = String.constructor do |string|
      string.upcase if string.present?
    end
  end

  register_macro(:phone_number_format) do
    key.failure("is invalid") if key? && !Phony.plausible?(value)
  end

  def initialize(input_params:, options: {})
    super(options)

    @input_params = input_params.to_h
  end

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end
end
