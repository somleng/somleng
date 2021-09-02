class AddIndexesOnPhoneCallsForToAndFrom < ActiveRecord::Migration[6.1]
  def change
    add_index(:phone_calls, :to)
    add_index(:phone_calls, :from)
  end
end
