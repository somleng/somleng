class AddCallerIDToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :phone_calls, :caller_id, :string
  end
end
