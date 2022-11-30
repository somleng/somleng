class AddMessagingServiceIDToMessages < ActiveRecord::Migration[7.0]
  def change
    add_reference(
      :messages,
      :messaging_service,
      type: :uuid,
      null: true,
      foreign_key: { on_delete: :nullify }
    )
  end
end
