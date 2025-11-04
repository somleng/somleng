# TODO: Delete this migration after staging is deployed
class CleanUpTablesOnStaging < ActiveRecord::Migration[8.1]
  def change
    drop_table :action_push_native_devices, if_exists: true
    drop_table :message_send_requests, if_exists: true
  end
end
