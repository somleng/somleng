class RemovePhoneNumberFromVerificationDeliveryAttempts < ActiveRecord::Migration[7.2]
  def change
    remove_reference(:verification_delivery_attempts, :phone_number, type: :uuid, foreign_key: { on_delete: :nullify })
  end
end
