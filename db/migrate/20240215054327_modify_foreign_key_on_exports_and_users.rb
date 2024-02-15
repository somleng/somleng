class ModifyForeignKeyOnExportsAndUsers < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key(:exports, :users)
    add_foreign_key(:exports, :users, on_delete: :cascade)
  end
end
