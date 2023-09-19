class AddStatusMessageToExports < ActiveRecord::Migration[7.0]
  def change
    add_column(:exports, :status_message, :string)
  end
end
