# This migration comes from action_push_native (originally 20250610075650)
class CreateActionPushNativeDevice < ActiveRecord::Migration[8.0]
  def change
    create_table :action_push_native_devices do |t|
      t.string :name
      t.string :platform, null: false
      t.string :token, null: false, index: { unique: true }
      t.belongs_to :owner, polymorphic: true, type: :uuid, null: false, index: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
