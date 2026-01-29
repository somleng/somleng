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
          CreateAccount.call(permitted_params)
        end
      end

      def update
        account = find_account

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
        account = find_account
        respond_with_resource(account, serializer_options)
      end

      def destroy
        account = find_account
        if DestroyAccount.call(account)
          respond_with_resource(account)
        else
          respond_with_errors(
            account,
            error_serializer_class: JSONAPIErrorsSerializer
          )
        end
      end

      private

      def accounts_scope
        current_carrier.accounts
      end

      def find_account
        accounts_scope.find(params[:id])
      end

      def serializer_options
        { serializer_class: AccountSerializer }
      end
    end
  end
end
