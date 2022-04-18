class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports, id: :uuid do |t|
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.string :resource_type, null: false
      t.references :user, foreign_key: { on_delete: :cascade }, type: :uuid, null: false
      t.references :carrier, foreign_key: { on_delete: :cascade }, type: :uuid, null: false

      t.timestamps
    end
  end
end
