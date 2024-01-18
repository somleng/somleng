class SetBeneficiaryDataToNullableForMessages < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:messages, :beneficiary_country_code, true)
    change_column_null(:messages, :beneficiary_fingerprint, true)
  end
end
