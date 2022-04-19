module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        optional(:id).filled(:str?)
        required(:type).filled(:str?, eql?: "phone_number")
        optional(:attributes).value(:hash).schema do
          optional(:number).filled(:str?, format?: PhoneNumber::NUMBER_FORMAT)
          optional(:enabled).filled(:bool?)
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
        key.failure("cannot be updated") if key? && resource.number != value
      elsif key?
        key.failure("already exists") if carrier.phone_numbers.exists?(number: value)
      else
        key.failure("is missing")
      end
    end

    relationship_rule(:account) do
      next unless key?

      account = carrier.accounts.find_by(id: value)
      if account.blank?
        key.failure("does not exist")
      elsif resource&.assigned?
        key.failure("cannot be updated") if resource.account != account
      end
    end

    def output
      result = super
      result[:account] = Account.find(result.fetch(:account)) if result.key?(:account)
      result
    end
  end
end
