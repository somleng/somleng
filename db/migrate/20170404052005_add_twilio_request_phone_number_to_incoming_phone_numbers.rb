class AddTwilioRequestPhoneNumberToIncomingPhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    add_column(:incoming_phone_numbers, :twilio_request_phone_number, :string)
  end
end
