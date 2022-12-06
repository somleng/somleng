class AddMessageIDAndPhoneCallIDToEvents < ActiveRecord::Migration[7.0]
  def up
    add_reference(
      :events,
      :message,
      type: :uuid,
      foreign_key: { on_delete: :nullify }
    )
    remove_column(:events, :eventable_type)
    rename_column(:events, :eventable_id, :phone_call_id)
    change_column_null(:events, :phone_call_id, true)
    add_index(:events, :phone_call_id)
    add_foreign_key(
      :events,
      :phone_calls,
      on_delete: :nullify
    )
  end

  def down
    remove_reference(:events, :message)
    rename_column(:events, :phone_call_id, :eventable_id)
    add_column(:events, :eventable_type, :string, null: false)
    add_index(
      :events,
      %i[eventable_type eventable_id],
      name: :index_events_on_eventable
    )
    change_column_null(:events, :eventable_id, false)
    remove_index(:events, :eventable_id)
    remove_foreign_key(:events, :phone_calls)
  end
end
