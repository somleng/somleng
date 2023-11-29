class ApplicationRequestSchema < Dry::Validation::Contract
  option :schema_helper, default: -> { RequestSchemaHelper.new }

  attr_reader :input_params

  delegate :success?, :errors, :context, to: :result

  module Types
    include Dry.Types()

    Number = String.constructor do |string|
      string.gsub(/\D/, "") if string.present?
    end

    UppercaseString = String.constructor do |string|
      string.upcase if string.present?
    end
  end

  register_macro(:date_range) do
    next unless key?
    next if value[:from_date].blank? && value[:to_date].blank?

    date_range = DateRange.new(from_date: value[:from_date], to_date: value[:to_date])

    next if date_range.valid?

    key(
      [*key.path.keys, :date_range].join(".")
    ).failure("invalid date range")
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
