class DropCustomDomains < ActiveRecord::Migration[7.0]
  def change
    drop_table :custom_domains
  end
end
