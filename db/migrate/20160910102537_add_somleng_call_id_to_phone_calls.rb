class AddSomlengCallIdToPhoneCalls < ActiveRecord::Migration[5.0]
  def change
    add_column(:phone_calls, :somleng_call_id, :string)
    add_index(:phone_calls, :somleng_call_id, :unique => true)
  end
end
