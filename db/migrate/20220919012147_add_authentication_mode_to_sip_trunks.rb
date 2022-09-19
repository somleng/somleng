class AddAuthenticationModeToSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    add_column(:sip_trunks, :authentication_mode, :string)

    reversible do |dir|
      dir.up do
        SIPTrunk.update_all(authentication_mode: :ip_address)
      end
    end

    change_column_null(:sip_trunks, :authentication_mode, false)
  end
end
