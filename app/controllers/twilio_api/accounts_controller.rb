module TwilioAPI
  class AccountsController < TwilioAPIController
    def show
      respond_with_resource(current_account, serializer_options)
    end

    private

    def serializer_options
      { serializer_class: AccountSerializer }
    end
  end
end
