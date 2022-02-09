class RemoveAttrEncryptedFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :encrypted_otp_secret, :string
    remove_column :users, :encrypted_otp_secret_salt, :string
    remove_column :users, :encrypted_otp_secret_iv, :string
  end
end
