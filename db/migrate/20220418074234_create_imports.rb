class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports, id: :uuid do |t|
      t.string :resource_type, null: false
      t.string :status, null: false
      t.string :error_message
      t.references :user, foreign_key: { on_delete: :cascade }, type: :uuid, null: false
      t.references :carrier, foreign_key: { on_delete: :cascade }, type: :uuid, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
