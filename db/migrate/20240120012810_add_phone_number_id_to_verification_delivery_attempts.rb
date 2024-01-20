class AddPhoneNumberIDToVerificationDeliveryAttempts < ActiveRecord::Migration[7.1]
  def change
    add_reference(:verification_delivery_attempts, :phone_number, type: :uuid, foreign_key: { on_delete: :nullify })
  end
end
