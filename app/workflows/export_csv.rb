require "csv"

class ExportCSV < ApplicationWorkflow
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  attr_reader :export

  def initialize(export)
    @export = export
  end

  def call
    Tempfile.open do |tmpfile|
      write_csv(tmpfile)
      attach_file(tmpfile)
    end
  end

  private

  def write_csv(file)
    CSV.open(file, "w") do |csv|
      csv << attribute_names

      ApplicationRecord.uncached do
        total_records = records.count
        records.find_each.with_index do |record, index|
          update_status_message!("#{format_number(index + 1)} of #{format_number(total_records, 'record')}") if (index % 500).zero?
          csv << serializer_class.new(record.decorated).as_csv
        end

        update_status_message!("Exported #{format_number(total_records, 'record')}")
      end
    end
  end

  def format_number(number, singular = nil)
    formatted_number = number_with_delimiter(number)
    return formatted_number if singular.blank?

    pluralize(formatted_number, singular)
  end

  def update_status_message!(message)
    export.update!(status_message: message)
  end

  def attach_file(csv)
    export.file.attach(
      io: csv,
      filename: export.name,
      content_type: "text/csv"
    )
  end

  def attribute_names
    serializer_class.new(resource_class.new).headers
  end

  def records
    resource_class.filter_class.new(
      resources_scope: resource_class,
      scoped_to: export.scoped_to,
      input_params: { filter: export.filter_params }
    ).apply
  end

  def serializer_class
    @serializer_class ||= resource_class.csv_serializer_class
  end

  def resource_class
    export.resource_type.constantize
  end
end
