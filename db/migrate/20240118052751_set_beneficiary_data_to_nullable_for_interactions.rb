class SetBeneficiaryDataToNullableForInteractions < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:interactions, :beneficiary_country_code, true)
    change_column_null(:interactions, :beneficiary_fingerprint, true)
  end
end
