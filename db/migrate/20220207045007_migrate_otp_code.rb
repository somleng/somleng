
# We just need this to migrate from attr_encrypted to use Rails encryption.
# We could remove the `encrypted_otp_*` after we run this migration.
# https://github.com/tinfoil/devise-two-factor/issues/192#issuecomment-1022504126
class MigrateOTPCode < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :otp_secret, :text

    User.reset_column_information

    User.where.not(encrypted_otp_secret: nil).find_each do |user|
      user.update!(
        otp_secret: Encryptor.decrypt(
          Base64.decode64(user.encrypted_otp_secret),
          key: Rails.configuration.app_settings.fetch(:otp_secret_encryption_key),
          iv: user.encrypted_otp_secret_iv.unpack1("m"),
          salt: user.encrypted_otp_secret_salt.slice(1..-1).unpack1("m")
        )
      )
    end

    remove_column :users, :encrypted_otp_secret
    remove_column :users, :encrypted_otp_secret_salt
    remove_column :users, :encrypted_otp_secret_iv
  end

  def down
    remove_column :users, :otp_secret
    add_column :users, :encrypted_otp_secret, :string
    add_column :users, :encrypted_otp_secret_salt, :string
    add_column :users, :encrypted_otp_secret_iv, :string
  end
end
