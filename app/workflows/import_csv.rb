require "csv"

class ImportCSV < ApplicationWorkflow
  attr_reader :import

  def initialize(import)
    @import = import
  end

  def call
    import_csv
  rescue ActiveRecord::RecordInvalid => e
    import.error_message = "Line #{import.error_line}: #{e.message}"
    import.fail!
  end

  private

  def import_csv
    import.file.open do |file|
      ApplicationRecord.transaction do
        CSV.foreach(file, headers: true).with_index do |row, index|
          import.error_line = index + 1
          create_phone_number(row) if import.resource_type == "PhoneNumber"
        end

        import.complete!
      end
    end
  end

  def create_phone_number(row)
    PhoneNumber.create!(
      carrier: import.carrier,
      number: row["number"],
      enabled: row.fetch("enabled", true)
    )
  end
end
