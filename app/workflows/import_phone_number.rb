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
    phone_number.type = data[:type]
    phone_number.enabled = data[:enabled].nil? ? true : data.fetch(:enabled)
    phone_number.iso_country_code = data.fetch(:country) if data[:country].present?
    phone_number.price = Money.from_amount(data.fetch(:price).to_d, import.carrier.billing_currency) if data[:price].present?

    phone_number.save!
    phone_number
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end
end
