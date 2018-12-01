module API
  module Usage
    class RecordsController < BaseController
      def show
        schema_validation_result = RecordCollectionRequestSchema.call(request.params)
        if schema_validation_result.success?
          usage_record_collection = UsageRecordCollection.new(
            current_account, schema_validation_result.output
          )
          respond_with(usage_record_collection, serializer_class: RecordCollectionSerializer)
        else
          respond_with(
            schema_validation_result,
            status: :unprocessable_entity,
            serializer_class: API::ErrorSerializer
          )
        end
      end
    end
  end
end
