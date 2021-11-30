class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.references :eventable, type: :uuid, polymorphic: true, null: false
      t.string :type, null: false
      t.jsonb :details, null: false, default: {}

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
