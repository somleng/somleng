require "csv"

class ImportCSV < ApplicationWorkflow
  attr_reader :import

  def initialize(import)
    @import = import
  end

  def call
    import_csv
  rescue Errors::ImportError => e
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
          case import.resource_type
          when "PhoneNumber"
            ImportPhoneNumber.call(import:, data: row_data)
          end
        end

        import.complete!
      end
    end
  end
end
