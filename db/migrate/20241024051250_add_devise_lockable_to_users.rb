class AddDeviseLockableToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column(:users, :failed_attempts, :integer, default: 0, null: false)
    add_column(:users, :unlock_token, :string)
    add_column(:users, :locked_at, :datetime)

    add_index(:users, :unlock_token, unique: true)
    add_index(:users, :confirmation_token, unique: true)
  end
end
