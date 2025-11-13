class CreateDestinationTariffs < ActiveRecord::Migration[8.0]
  def change
    create_table :destination_tariffs, id: :uuid do |t|
      t.references :schedule, null: false, foreign_key: { to_table: :tariff_schedules, on_delete: :cascade }, type: :uuid
      t.references :destination_group, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :tariff, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:destination_tariffs, [ :schedule_id, :tariff_id ], unique: true)
    add_index(:destination_tariffs, [ :schedule_id, :destination_group_id ], unique: true)
  end
end
