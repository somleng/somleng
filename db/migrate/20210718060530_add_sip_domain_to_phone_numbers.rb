class AddSIPDomainToPhoneNumbers < ActiveRecord::Migration[6.1]
  def change
    add_column :phone_numbers, :sip_domain, :string
  end
end
