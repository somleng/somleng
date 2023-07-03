require "csv"

class ImportCSV < ApplicationWorkflow
  attr_reader :import

  class InvalidAccountError < StandardError; end

  def initialize(import)
    @import = import
  end

  def call
    import_csv
  rescue ActiveRecord::RecordInvalid, InvalidAccountError => e
    import.error_message = "Line #{import.error_line}: #{e.message}"
    import.fail!
  end

  private

  def import_csv
    import.file.open do |file|
      ApplicationRecord.transaction do
        CSV.foreach(file, headers: true).with_index do |row, index|
          row_data = row.to_h.transform_keys { |key| key.to_s.parameterize.underscore }

          import.error_line = index + 1
          create_phone_number(row_data) if import.resource_type == "PhoneNumber"
        end

        import.complete!
      end
    end
  end

  def create_phone_number(row)
    PhoneNumber.create!(
      carrier: import.carrier,
      number: row["number"],
      enabled: row.fetch("enabled", true),
      account: find_account(row["account_sid"])
    )
  end

  def find_account(account_id)
    return if account_id.blank?

    account = import.carrier.accounts.find_by(id: account_id)
    raise InvalidAccountError, "account_sid is invalid" if account.blank?

    account
  end
end
