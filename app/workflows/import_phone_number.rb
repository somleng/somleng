class ImportPhoneNumber < ApplicationWorkflow
  attr_reader :import, :data, :phone_number_country_assignment_rules

  class Error < Errors::ImportError; end

  def initialize(import, data, phone_number_country_assignment_rules: PhoneNumberCountryAssignmentRules.new)
    @import = import
    @data = data
    @phone_number_country_assignment_rules = phone_number_country_assignment_rules
  end

  def call
    create_phone_number!
  end

  private

  def create_phone_number!
    PhoneNumber.create!(
      carrier: import.carrier,
      number: data["number"],
      enabled: data.fetch("enabled", true),
      account: find_account(data["account_sid"]),
      iso_country_code: assign_country(
        number: data["number"],
        iso_country_code: data["country"],
        existing_country:
      )
    )
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def find_account(account_id)
    return if account_id.blank?

    account = import.carrier.accounts.find_by(id: account_id)
    raise Error, "account_sid is invalid" if account.blank?

    account
  end

  def assign_country(number:, iso_country_code:, existing_country:)
    phone_number_country_assignment_rules.assign_country(
      number:,
      preferred_country: ISO3166::Country.new(iso_country_code),
      fallback_country: import.carrier.country,
      existing_country:
    )
  end
end
