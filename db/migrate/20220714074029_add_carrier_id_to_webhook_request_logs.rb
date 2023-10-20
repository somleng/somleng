class AddCarrierIDToWebhookRequestLogs < ActiveRecord::Migration[7.0]
  def change
    add_reference :webhook_request_logs, :carrier, type: :uuid

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE webhook_request_logs logs
          SET carrier_id = events.carrier_id
          FROM events where events.id = logs.event_id
        SQL
      end
    end

    change_column_null(:webhook_request_logs, :carrier_id, false)
  end
end
