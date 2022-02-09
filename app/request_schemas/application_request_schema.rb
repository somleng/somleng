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

  register_macro(:date_range) do
    if key?
      from_date = value[:from_date]
      to_date = value[:to_date]
      empty_range = from_date.blank? && to_date.blank?
      valid_range = from_date.present? && to_date.present? && to_date >= from_date

      key([*key.path.keys, :date_range].join(".")).failure("invalid date range") unless empty_range || valid_range
    end
  end

  def initialize(input_params:, options: {})
    super(**options)

    @input_params = input_params.to_h.with_indifferent_access
  end

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end
end
