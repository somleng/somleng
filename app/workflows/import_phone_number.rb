class ImportPhoneNumber < ApplicationWorkflow
  attr_reader :import, :data

  class Error < Errors::ImportError; end

  def initialize(import:, data:)
    @import = import
    @data = data.with_indifferent_access
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
    phone_number.type = sanitize(data.fetch(:type)) if data[:type].present?
    phone_number.price = Money.from_amount(data.fetch(:price).to_d, import.carrier.billing_currency) if data[:price].present?
    phone_number.visibility = sanitize(data.fetch(:visibility)) if data[:visibility].present?
    phone_number.iso_country_code = sanitize(data.fetch(:country)) if data[:country].present?
    phone_number.iso_region_code = sanitize(data.fetch(:region)) if data[:region].present?
    phone_number.locality = sanitize(data.fetch(:locality)) if data[:locality].present?

    phone_number.save!
    phone_number
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def sanitize(data)
    data.squish
  end
end
