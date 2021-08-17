module CarrierAPI
  module V1
    class AccountsController < CarrierAPIController
      def index
        validate_request_schema(with: AccountFilterRequestSchema) do |permitted_params|
          accounts_scope.where(permitted_params)
        end
      end

      def create
        validate_request_schema(with: AccountRequestSchema) do |permitted_params|
          accounts_scope.create!(permitted_params)
        end
      end

      def update
        account = accounts_scope.find(params[:id])

        validate_request_schema(
          with: UpdateAccountRequestSchema,
          schema_options: { resource: account }
        ) do |permitted_params|
          account.update!(permitted_params)
          account
        end
      end

      def show
        respond_with_resource(accounts_scope.find(params[:id]))
      end

      private

      def accounts_scope
        current_card_issuer.accounts
      end
    end
  end
end
