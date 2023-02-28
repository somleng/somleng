class AddDeliveredAtToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :delivered_at, :datetime
  end
end
