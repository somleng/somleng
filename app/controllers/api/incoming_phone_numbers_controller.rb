class Api::IncomingPhoneNumbersController < Api::PublicController
  private

  def association_chain
    current_account.incoming_phone_numbers
  end
end
