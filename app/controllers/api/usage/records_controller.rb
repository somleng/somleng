class Api::Usage::RecordsController < Api::BaseController
  def show
    schema_validation_result = UsageRecordCollectionRequestSchema.schema.call(request.params)
    if schema_validation_result.success?
      usage_record_collection = UsageRecordCollection.new(
        filter_params: schema_validation_result.output,
        account: current_account
      )
      respond_with(usage_record_collection)
    else
      respond_with(
        schema_validation_result,
        status: :unprocessable_entity,
        serializer_class: ApiErrorSerializer
      )
    end
  end
end
