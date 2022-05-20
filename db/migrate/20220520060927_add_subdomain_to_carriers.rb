class AddSubdomainToCarriers < ActiveRecord::Migration[7.0]
  def change
    enable_extension("citext")
    add_column(:carriers, :subdomain, :citext)

    reversible do |dir|
      dir.up do
        Carrier.where(subdomain: nil).each do |carrier|
          carrier.update_columns(subdomain: carrier.name.parameterize)
        end
      end
    end

    change_column_null(:carriers, :subdomain, false)
    add_index(:carriers, :subdomain, unique: true)
  end
end
