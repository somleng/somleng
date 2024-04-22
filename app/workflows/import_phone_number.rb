class ImportPhoneNumber < ApplicationWorkflow
  attr_reader :import, :data, :phone_number_country_assignment_rules

  class Error < Errors::ImportError; end

  def initialize(import:, data:, phone_number_country_assignment_rules: PhoneNumberCountryAssignmentRules.new)
    @import = import
    @data = data.with_indifferent_access
    @phone_number_country_assignment_rules = phone_number_country_assignment_rules
  end

  def call
    create_phone_number!
  end

  private

  def create_phone_number!
    phone_number = PhoneNumber.find_or_initialize_by(
      number: data[:number],
      carrier: import.carrier
    )
    phone_number.type = data[:type]
    phone_number.enabled = data[:enabled].nil? ? true : data.fetch(:enabled)
    phone_number.iso_country_code = country_for(
      number: data[:number],
      iso_country_code: data[:country],
      existing_country: phone_number.country
    )&.alpha2

    raise Error.new("both price and currency must be set") if data.values_at(:price, :currency).compact.one?

    if data[:price].present? && data[:currency].present?
      phone_number.price = Money.from_amount(data.fetch(:price).to_d, data.fetch(:currency))
    end

    phone_number.save!
    phone_number
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def country_for(number:, iso_country_code:, existing_country:)
    return if number.blank?

    phone_number_country_assignment_rules.country_for(
      number:,
      preferred_country: ISO3166::Country.new(iso_country_code),
      fallback_country: import.carrier.country,
      existing_country:
    )
  end
end
