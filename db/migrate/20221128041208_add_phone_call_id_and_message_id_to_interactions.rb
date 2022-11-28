class AddPhoneCallIDAndMessageIDToInteractions < ActiveRecord::Migration[7.0]
  def up
    add_reference(
      :interactions,
      :message,
      type: :uuid,
      foreign_key: { on_delete: :nullify },
      index: { unique: true }
    )
    remove_index(:interactions, name: :index_interactions_on_interactable)
    add_index(:interactions, :interactable_type)
    rename_column(:interactions, :interactable_id, :phone_call_id)
    change_column_null(:interactions, :phone_call_id, true)
    add_index(:interactions, :phone_call_id, unique: true)
    add_foreign_key(
      :interactions,
      :phone_calls,
      on_delete: :nullify
    )
  end

  def down
    remove_reference(:interactions, :message)
    rename_column(:interactions, :phone_call_id, :interactable_id)
    remove_index(:interactions, :interactable_type)
    add_index(
      :interactions,
      %i[interactable_type interactable_id],
      unique: true,
      name: :index_interactions_on_interactable
    )
    change_column_null(:interactions, :interactable_id, false)
    remove_index(:interactions, :interactable_id)
    remove_foreign_key(:interactions, :phone_calls)
  end
end
