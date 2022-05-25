class AddCustomAppHostAndCustomAPIHostToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :custom_app_host, :citext
    add_column :carriers, :custom_api_host, :citext
    add_index :carriers, :custom_app_host, unique: true
    add_index :carriers, :custom_api_host, unique: true
  end
end
