module API
  class IncomingPhoneNumbersController < BaseController
    private

    def association_chain
      current_account.incoming_phone_numbers
    end
  end
end
