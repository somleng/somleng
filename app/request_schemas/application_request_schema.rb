class ApplicationRequestSchema < Dry::Validation::Contract
  attr_reader :input_params

  delegate :success?, :errors, to: :result

  module Types
    include Dry.Types()

    PhoneNumber = String.constructor do |string|
      PhonyRails.normalize_number(string)
    end

    UppercaseString = String.constructor do |string|
      string.upcase if string.present?
    end
  end

  register_macro(:phone_number_format) do |macro:|
    if key? && !Phony.plausible?(value)
      key.failure(
        { text: "is invalid", code: macro.args.dig(0, :error_code) }.compact
      )
    end
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
