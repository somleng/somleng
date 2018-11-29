require_relative "usage_record_schema"

module APIResponseSchema
  UsageRecordCollectionSchema = Dry::Validation.Schema do
    required(:first_page_uri).filled(:str?)
    required(:previous_page_uri).maybe(:str?)
    required(:next_page_uri).maybe(:int?)
    required(:page).filled(:int?)
    required(:uri).filled(:str?)
    required(:page_size).filled(:int?)
    required(:usage_records).each(schema: UsageRecordSchema)
  end
end
