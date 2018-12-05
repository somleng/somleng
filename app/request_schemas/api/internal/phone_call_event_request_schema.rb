module API
  module Internal
    PhoneCallEventRequestSchema = Dry::Validation.Params(ApplicationRequestSchema) do
      EVENT_TYPES = %w[ringing answered completed recording_started recording_completed].freeze
      required(:type, :string).filled(:str?, included_in?: EVENT_TYPES)
      required(:phone_call_id, :string).filled(:str?)
      optional(:params, :hash).maybe(:hash?)
    end
  end
end
