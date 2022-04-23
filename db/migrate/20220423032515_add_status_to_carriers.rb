class AddStatusToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :status, :string

    reversible do |dir|
      dir.up do
        Carrier.update_all(status: :enabled)
      end
    end

    change_column_null :carriers, :status, false
  end
end
