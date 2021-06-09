class CreateAccountMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :account_memberships, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :role, null: false
      t.index %i[account_id user_id], unique: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_column(:accounts, :account_memberships_count, :integer, null: false, default: 0, index: true)
  end
end
