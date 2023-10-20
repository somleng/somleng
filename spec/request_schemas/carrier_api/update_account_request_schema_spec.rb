require "rails_helper"

module CarrierAPI
  RSpec.describe UpdateAccountRequestSchema, type: :request_schema do
    it "validates customer managed attributes" do
      carrier = create(:carrier)
      customer_managed_account = create(:account, carrier:)
      create(:account_membership, :owner, account: customer_managed_account)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "account",
              id: customer_managed_account.id,
              attributes: {
                name: "Foobar"
              }
            }
          },
          options: {
            carrier:,
            resource: customer_managed_account
          }
        )
      ).not_to have_valid_field(:data, :attributes, :name)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "account",
              id: customer_managed_account.id,
              attributes: {
                default_tts_voice: "Basic.Kal"
              }
            }
          },
          options: {
            carrier:,
            resource: customer_managed_account
          }
        )
      ).not_to have_valid_field(:data, :attributes, :default_tts_voice)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "account",
              id: customer_managed_account.id,
              attributes: {
                status: "disabled"
              }
            }
          },
          options: {
            carrier:,
            resource: customer_managed_account
          }
        )
      ).to have_valid_field(:data, :attributes, :status)
    end

    def validate_request_schema(...)
      UpdateAccountRequestSchema.new(...)
    end
  end
end
