module API
  module Internal
    class PhoneCallRequestSchema < ApplicationRequestSchema
      define_schema do
        required(:To, :string).filled(:str?)
        required(:From, :string).filled(:str?)
        required(:ExternalSid, :string).filled(:str?)
        required(:Variables, :hash).filled(:hash?)
      end
    end
  end
end
