class AddWebsiteToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :website, :string
  end
end
