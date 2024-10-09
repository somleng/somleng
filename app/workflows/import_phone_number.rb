class ImportPhoneNumber < ApplicationWorkflow
  attr_reader :import, :data

  class Error < Errors::ImportError; end

  def initialize(import:, data:)
    @import = import
    @data = data.with_indifferent_access
  end

  def call
    marked_for_deletion? ? delete_phone_number! : create_phone_number!
  end

  private

  def create_phone_number!
    raise Error.new("Cannot create phone numbers when import contains 'marked_for_deletion' flags. Remove the 'marked_for_deletion' column and try again") if data.key?(:marked_for_deletion)

    phone_number = PhoneNumber.find_or_initialize_by(
      number: data[:number],
      carrier: import.carrier
    )
    phone_number.type = sanitize(data.fetch(:type)) if data[:type].present?
    phone_number.price = Money.from_amount(data.fetch(:price).to_d, import.carrier.billing_currency) if data[:price].present?
    phone_number.visibility = sanitize(data.fetch(:visibility)) if data[:visibility].present?
    phone_number.iso_country_code = sanitize(data.fetch(:country)) if data[:country].present?
    phone_number.iso_region_code = sanitize(data.fetch(:region)) if data[:region].present?
    phone_number.locality = sanitize(data.fetch(:locality)) if data[:locality].present?
    phone_number.rate_center = sanitize(data.fetch(:rate_center)).upcase if data[:rate_center].present?
    phone_number.lata = sanitize(data.fetch(:lata)) if data[:lata].present?
    phone_number.metadata = extract_metadata(data)

    phone_number.save!
    phone_number
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def delete_phone_number!
    phone_number = PhoneNumber.find_by(
      number: data[:number],
      carrier: import.carrier
    )

    raise Error.new("Cannot find phone number") if phone_number.blank?

    phone_number.destroy!
  rescue ActiveRecord::RecordNotDestroyed => e
    raise Error.new(e)
  end

  def sanitize(data)
    data.to_s.squish.presence
  end

  def marked_for_deletion?
    return if data[:marked_for_deletion].blank?
    raise Error.new("'marked_for_deletion' must be set to true'") if data.fetch(:marked_for_deletion).downcase != "true"
    raise Error.new("must contain only 'number' and 'marked_for_deletion'") if data.keys.difference([ "number", "marked_for_deletion" ]).any?

    true
  end

  def extract_metadata(data)
    data.select { |k, _v| k.start_with?("meta_") }
        .transform_keys { |k| k.delete_prefix("meta_") }
        .transform_values { |v| sanitize(v) }
  end
end
