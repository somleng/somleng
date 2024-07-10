class AddParentCallIDToPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    add_reference(
      :phone_calls,
      :parent_call,
      type: :uuid,
      foreign_key: {
        to_table: :phone_calls,
        on_delete: :cascade
      }
    )
  end
end
