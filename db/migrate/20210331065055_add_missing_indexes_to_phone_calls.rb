class AddMissingIndexesToPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    add_index :phone_calls, :status
    add_index :phone_calls, :direction
  end
end
