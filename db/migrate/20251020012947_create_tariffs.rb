class CreateTariffs < ActiveRecord::Migration[8.0]
  def change
    create_table :tariffs, id: :uuid do |t|
      t.references :carrier, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :category, null: false
      t.string :currency, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
