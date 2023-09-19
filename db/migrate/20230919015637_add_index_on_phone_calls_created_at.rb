class AddIndexOnPhoneCallsCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index(:phone_calls, :created_at)
  end
end
