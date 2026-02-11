class AddDirectionToPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    add_column :phone_calls, :direction, :string, null: false
  end
end
