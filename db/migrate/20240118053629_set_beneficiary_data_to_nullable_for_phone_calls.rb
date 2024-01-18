class SetBeneficiaryDataToNullableForPhoneCalls < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:phone_calls, :beneficiary_country_code, true)
    change_column_null(:phone_calls, :beneficiary_fingerprint, true)
  end
end
