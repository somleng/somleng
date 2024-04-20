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
    phone_number.enabled = data.fetch(:enabled, true)

    phone_number.iso_country_code = assign_country(
      number: data[:number],
      iso_country_code: data[:country],
      existing_country: phone_number.country
    )&.alpha2

    phone_number.save!
    phone_number
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def assign_country(number:, iso_country_code:, existing_country:)
    return if number.blank?

    phone_number_country_assignment_rules.assign_country(
      number:,
      preferred_country: ISO3166::Country.new(iso_country_code),
      fallback_country: import.carrier.country,
      existing_country:
    )
  end
end
