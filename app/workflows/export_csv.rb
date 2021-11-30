require "csv"

class ExportCSV < ApplicationWorkflow
  attr_reader :export

  def initialize(export)
    @export = export
  end

  def call
    csv = generate_csv
    attach_file(csv)
  end

  private

  def generate_csv
    CSV.generate do |csv|
      csv << attribute_names

      records.find_each do |record|
        csv << serializer_class.new(record.decorated).as_csv
      end
    end
  end

  def attribute_names
    serializer_class.new(resource_class.new).headers
  end

  def attach_file(csv)
    export.file.attach(
      io: StringIO.new(csv),
      filename: export.name,
      content_type: "text/csv"
    )
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
