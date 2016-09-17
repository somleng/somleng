class AddIncomingPhoneNumberIdToPhoneCalls < ActiveRecord::Migration[5.0]
  def change
    add_reference(:phone_calls, :incoming_phone_number, :index => true, :foreign_key => true, :type => :uuid)
  end
end
