class CreateDestinationGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :destination_groups, id: :uuid do |t|
      t.references :carrier, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.citext :name, null: false
      t.boolean :catch_all, null: false, default: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:destination_groups, [ :carrier_id, :name, :created_at ])
    add_index(:destination_groups, [ :carrier_id, :catch_all ], unique: true, where: "catch_all = true")
  end
end
