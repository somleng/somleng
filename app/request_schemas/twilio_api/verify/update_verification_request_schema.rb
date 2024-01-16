module TwilioAPI
  module Verify
    class UpdateVerificationRequestSchema < TwilioAPIRequestSchema
      class VerificationStatusEvent
        attr_reader :verification

        EVENTS = {
          "approved" => :approve,
          "canceled" => :cancel
        }.freeze

        def initialize(verification)
          @verification = verification
        end

        def may_transition_to?(new_state)
          return false unless EVENTS.key?(new_state)

          verification.may_fire_event?(EVENTS.fetch(new_state))
        end

        def event(new_state)
          EVENTS.fetch(new_state)
        end
      end

      option :verification

      params do
        required(:Status).filled(:str?, included_in?: %w[approved canceled])
      end

      rule(:Status) do
        verification_status_event = VerificationStatusEvent.new(verification)
        unless verification_status_event.may_transition_to?(value)
          base.failure(schema_helper.build_schema_error(:verify_invalid_verification_status))
        end
      end

      def output
        params = super

        {
          event: VerificationStatusEvent.new(verification).event(params.fetch(:Status))
        }
      end
    end
  end
end
