class CreateDestinationPrefixes < ActiveRecord::Migration[8.0]
  def change
    create_table :destination_prefixes, id: :uuid do |t|
      t.references :destination_group, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :prefix, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:destination_prefixes, [ :destination_group_id, :prefix ], unique: true)
  end
end
