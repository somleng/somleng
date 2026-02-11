class AddSubdomainToCarriers < ActiveRecord::Migration[7.0]
  def change
    enable_extension("citext")
    add_column(:carriers, :subdomain, :citext, null: false)
    add_index(:carriers, :subdomain, unique: true)
  end
end
