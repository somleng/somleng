class AddInternalToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :internal, :boolean, null: false, default: false
    add_index :messages, :internal
    add_index :messages, :created_at
  end
end
