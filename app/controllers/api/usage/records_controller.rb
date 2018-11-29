module API
  module Usage
    class RecordsController < BaseController
      def show
        schema_validation_result = UsageRecordCollectionRequestSchema.schema.call(request.params)
        if schema_validation_result.success?
          usage_record_collection = UsageRecordCollection.new(
            current_account, schema_validation_result.output
          )
          respond_with(usage_record_collection)
        else
          respond_with(
            schema_validation_result,
            status: :unprocessable_entity,
            serializer_class: APIErrorSerializer
          )
        end
      end
    end
  end
end
