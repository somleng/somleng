class AddAuthenticationModeUsernameAndPasswordToSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    add_column(:sip_trunks, :authentication_mode, :string, null: false)
    add_column(:sip_trunks, :username, :string)
    add_column(:sip_trunks, :password, :string)
    add_index(:sip_trunks, :username, unique: true)
  end
end
