class AddAlphanumericSenderIDToMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :messages,
      :alphanumeric_sender_id,
      type: :uuid,
      foreign_key: { on_delete: :nullify }
    )
  end
end
