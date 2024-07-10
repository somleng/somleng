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

    reversible do |dir|
      dir.up do
        PhoneCall.where(direction: "outbound").update_all(direction: "outbound_api")
      end
    end
  end
end
