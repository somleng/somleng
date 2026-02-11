class AddCarrierIDToWebhookRequestLogs < ActiveRecord::Migration[7.0]
  def change
    add_reference :webhook_request_logs, :carrier, type: :uuid, null: false
  end
end
