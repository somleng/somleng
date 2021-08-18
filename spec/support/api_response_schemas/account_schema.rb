module APIResponseSchema
  AccountSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "account")

    required(:attributes).schema do
      required(:name).filled(:str?)
      required(:status).filled(:bool?)
      required(:status).filled(:str?, included_in?: Account.status.values)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end

    optional(:relationships).schema do
      optional(:outbound_sip_trunk).schema do
        required(:data).schema do
          required(:id).filled(:str?)
          required(:type).filled(eql?: "outbound_sip_trunk")
        end
      end
    end
  end
end
