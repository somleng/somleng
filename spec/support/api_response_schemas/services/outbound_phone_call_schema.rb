module APIResponseSchema
  module Services
    OutboundPhoneCallSchema = Dry::Schema.Params do
      required(:sid).filled(:str?)
      required(:parent_call_sid).filled(:str?)
      required(:destination).filled(:str?)
      required(:dial_string_prefix).maybe(:str?)
      required(:plus_prefix).filled(:bool?)
      required(:national_dialing).filled(:bool?)
      required(:host).filled(:str?)
      required(:username).maybe(:str?)
      required(:symmetric_latching).filled(:bool?)
    end
  end
end
