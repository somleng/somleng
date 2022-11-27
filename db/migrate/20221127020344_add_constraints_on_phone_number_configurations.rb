class AddConstraintsOnPhoneNumberConfigurations < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:phone_number_configurations, :phone_number_id, false)
    remove_index(:phone_number_configurations, :phone_number_id)
    add_index(:phone_number_configurations, :phone_number_id, unique: true)
  end
end
