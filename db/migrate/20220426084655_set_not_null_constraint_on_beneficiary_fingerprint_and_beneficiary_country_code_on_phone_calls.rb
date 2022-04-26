class SetNotNullConstraintOnBeneficiaryFingerprintAndBeneficiaryCountryCodeOnPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    change_column_null :phone_calls, :beneficiary_country_code, false
    change_column_null :phone_calls, :beneficiary_fingerprint, false
  end
end
