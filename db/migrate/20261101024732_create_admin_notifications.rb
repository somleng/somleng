class CreateAdminNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_notifications, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.string :email, null: false
      t.string :topic, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end

    add_index(:admin_notifications, [ :user_id, :topic, :created_at ])
  end
end
