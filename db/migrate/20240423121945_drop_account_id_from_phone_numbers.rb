class DropAccountIDFromPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    remove_column(:phone_numbers, :account_id, type: :uuid)
  end
end
