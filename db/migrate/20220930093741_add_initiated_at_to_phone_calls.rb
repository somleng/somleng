class AddInitiatedAtToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    add_column(:phone_calls, :initiated_at, :datetime)
    add_index(:phone_calls, :initiated_at)
  end
end
