class AddUniqueIndexOnDestinationTariffsTariffID < ActiveRecord::Migration[8.1]
  def change
    remove_index(:destination_tariffs, [ :schedule_id, :tariff_id ], unique: true)
    remove_index(:destination_tariffs, :tariff_id)
    add_index(:destination_tariffs, :tariff_id, unique: true) # make tariff one-to-one with destination tariffs
  end
end
