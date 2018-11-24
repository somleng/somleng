class UsageRecordCollectionRequestSchema < ApplicationRequestSchema
  define_schema do
    optional(:Category, :string).filled(eql?: "calls")
    optional(:StartDate, :date).filled(:date?)
    optional(:EndDate, :date).filled(:date?)
  end
end
