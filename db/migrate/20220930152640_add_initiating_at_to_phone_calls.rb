class AddInitiatingAtToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    add_column(:phone_calls, :initiating_at, :datetime)
    add_index(:phone_calls, :initiating_at)
  end
end
