module ResponseSchema
  module API
    module Internal
      PhoneCallEventSchema = Dry::Validation.Schema do
        optional(:recording_url).maybe(:str?)
      end
    end
  end
end
