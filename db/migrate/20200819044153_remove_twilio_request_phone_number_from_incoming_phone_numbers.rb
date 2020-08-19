class RemoveTwilioRequestPhoneNumberFromIncomingPhoneNumbers < ActiveRecord::Migration[6.0]
  def change
    remove_column(:incoming_phone_numbers, :twilio_request_phone_number)
  end
end
