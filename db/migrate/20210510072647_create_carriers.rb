class CreateCarriers < ActiveRecord::Migration[6.1]
  def change
    create_table :carriers, id: :uuid do |t|
      t.string :name, null: false
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
