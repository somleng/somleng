class CreateAccountMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :account_memberships, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :role, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
