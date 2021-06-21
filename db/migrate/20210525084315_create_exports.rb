class CreateExports < ActiveRecord::Migration[6.1]
  def change
    create_table :exports, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.jsonb :filter_params, null: false, default: {}
      t.jsonb :scoped_to, null: false, default: {}
      t.string :name, null: false
      t.string :resource_type, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
