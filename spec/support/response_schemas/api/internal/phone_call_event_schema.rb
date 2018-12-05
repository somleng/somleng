module ResponseSchema
  module API
    module Internal
      PhoneCallEventSchema = Dry::Validation.Schema do
        required(:recording_url).filled(:str?)
      end
    end
  end
end
