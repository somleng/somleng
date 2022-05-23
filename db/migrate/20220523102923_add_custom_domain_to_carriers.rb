class AddCustomDomainToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :custom_domain, :citext
    add_index :carriers, :custom_domain, unique: true
  end
end
