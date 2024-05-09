class AddColumnsForLiveCallUpdatesToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_calls, :call_service_host, :inet)
    add_column(:phone_calls, :user_terminated_at, :datetime)
    add_index(:phone_calls, :user_terminated_at)
    add_column(:phone_calls, :user_updated_at, :datetime)
    add_index(:phone_calls, :user_updated_at)
  end
end
