class AddPriceToCallDataRecords < ActiveRecord::Migration[5.0]
  def up
    change_table :call_data_records do |t|
      t.monetize :price,
                 :amount =>   {:column_name => :price_microunits, :default => nil, :null => true},
                 :currency => {:default => nil, :null => true}
    end

    CallDataRecord.update_all(
      :price_currency => CallDataRecord::DEFAULT_PRICE_STORE_CURRENCY,
      :price_microunits => 0
    )

    change_column(:call_data_records, :price_microunits, :integer, :null => false)
    change_column(:call_data_records, :price_currency,   :string,  :null => false)
  end

  def down
    remove_column(:call_data_records, :price_microunits)
    remove_column(:call_data_records, :price_currency)
  end
end
