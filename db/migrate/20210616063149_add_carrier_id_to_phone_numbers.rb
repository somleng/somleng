class AddCarrierIDToPhoneNumbers < ActiveRecord::Migration[6.1]
  def change
    add_reference :phone_numbers, :carrier, foreign_key: true, type: :uuid

    reversible do |dir|
      dir.up do
        execute <<-SQL
        UPDATE phone_numbers pn
        SET carrier_id = a.carrier_id
        FROM accounts a where pn.account_id = a.id
        SQL
      end
    end

    rename_column(:phone_numbers, :phone_number, :number)
    change_column_null(:phone_numbers, :carrier_id, false)
    change_column_null(:phone_numbers, :account_id, true)
    change_column_null(:phone_numbers, :voice_url, true)
    change_column_null(:phone_numbers, :voice_method, true)
    remove_index(:phone_numbers, :number)
    add_index(:phone_numbers, :number)
    add_index(:phone_numbers, %i[number carrier_id], unique: true)
  end
end
