module CarrierAPI
  module V1
    class AccountsController < CarrierAPIController
      def index
        respond_with_resource(accounts_scope, serializer_options)
      end

      def create
        validate_request_schema(
          with: AccountRequestSchema, **serializer_options
        ) do |permitted_params|
          accounts_scope.create!(permitted_params)
        end
      end

      def update
        account = accounts_scope.find(params[:id])

        validate_request_schema(
          with: UpdateAccountRequestSchema,
          schema_options: { resource: account },
          **serializer_options
        ) do |permitted_params|
          account.update!(permitted_params)
          account
        end
      end

      def show
        respond_with_resource(accounts_scope.find(params[:id]), serializer_options)
      end

      private

      def accounts_scope
        current_carrier.accounts
      end

      def serializer_options
        { serializer_class: AccountSerializer }
      end
    end
  end
end
