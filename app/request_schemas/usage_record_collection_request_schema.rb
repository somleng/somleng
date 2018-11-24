class UsageRecordCollectionRequestSchema < ApplicationRequestSchema
  define_schema do
    optional(:Category, :string).filled(included_in?: UsageRecordCollection::DEFAULT_CATEGORIES)
    optional(:StartDate, :date).filled(:date?)
    optional(:EndDate, :date).filled(:date?)
  end
end
