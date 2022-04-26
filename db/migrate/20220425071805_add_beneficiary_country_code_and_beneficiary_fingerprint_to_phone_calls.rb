class AddBeneficiaryCountryCodeAndBeneficiaryFingerprintToPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    add_column :phone_calls, :beneficiary_country_code, :string
    add_column :phone_calls, :beneficiary_fingerprint, :string

    add_index :phone_calls, :beneficiary_fingerprint
    add_index :phone_calls, :beneficiary_country_code
  end
end
