class AddInternalToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_column :phone_calls, :internal, :boolean, null: false, default: false
    add_index :phone_calls, :internal
  end
end
