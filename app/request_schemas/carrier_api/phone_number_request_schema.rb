module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        optional(:id).filled(:str?)
        required(:type).filled(:str?, eql?: "phone_number")
        required(:attributes).value(:hash).schema do
          optional(:number).filled(:str?)
          optional(:voice_url).filled(:str?, format?: URL_FORMAT)
          optional(:voice_method).value(
            ApplicationRequestSchema::Types::UppercaseString,
            :filled?,
            included_in?: PhoneNumber.voice_method.values
          )
          optional(:status_callback_url).filled(:string, format?: URL_FORMAT)
          optional(:status_callback_method).value(
            ApplicationRequestSchema::Types::UppercaseString,
            :filled?,
            included_in?: PhoneNumber.status_callback_method.values
          )
        end

        optional(:relationships).value(:hash).schema do
          required(:account).value(:hash).schema do
            required(:data).value(:hash).schema do
              required(:type).filled(:str?, eql?: "account")
              required(:id).filled(:str?)
            end
          end
        end
      end
    end

    attribute_rule(:number) do
      if resource.present?
        key.failure("already exists") if key? && carrier.phone_numbers.where.not(id: resource.id).exists?(number: value)
      elsif key?
        key.failure("already exists") if carrier.phone_numbers.exists?(number: value)
      else
        key.failure("is missing")
      end
    end

    relationship_rule(:account) do
      key.failure("does not exist") if key? && !carrier.accounts.exists?(id: value)
    end

    def output
      result = super
      result[:account] = Account.find(result.fetch(:account)) if result.key?(:account)
      result[:voice_method] ||= "POST" if result.key?(:voice_url)
      result
    end
  end
end
