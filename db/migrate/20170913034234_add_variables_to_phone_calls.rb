class AddVariablesToPhoneCalls < ActiveRecord::Migration[5.1]
  def change
    add_column(:phone_calls, :variables, :json, :null => false, :default => {})
    add_column(:phone_calls, :twilio_request_to, :string)
    add_column(:phone_calls, :twilio_request_from, :string)
  end
end
