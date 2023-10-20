class AddForeignKeyOnWebhookRequestLogsToCarrier < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key(:webhook_request_logs, :carriers)
  end
end
