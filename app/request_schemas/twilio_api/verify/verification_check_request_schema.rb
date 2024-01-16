module TwilioAPI
  module Verify
    class VerificationCheckRequestSchema < TwilioAPIRequestSchema
      option :verification_service
      option :verifications_scope

      params do
        required(:Code).filled(:str?)
        optional(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        optional(:VerificationSid).filled(:str?)
      end

      rule(:To, :VerificationSid) do |context:|
        if !key?(:To) && !key?(:VerificationSid)
          next base.failure(schema_helper.build_schema_error(:no_target_verification_specified))
        end

        if key?(:VerificationSid)
          context[:verification] = verifications_scope.find(values.fetch(:VerificationSid))
        elsif key?(:To)
          context[:verification] = verifications_scope.find_by!(to: values.fetch(:To))
        end

        if context[:verification].max_check_attempts_reached?
          base.failure(schema_helper.build_schema_error(:max_check_attempts_reached))
        end
      end

      def output
        params = super

        {
          verification: context.fetch(:verification),
          code: params.fetch(:Code)
        }
      end
    end
  end
end
