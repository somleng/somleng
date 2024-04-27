class AddVisibilityToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :visibility, :string)
    add_index(:phone_numbers, :visibility)

    reversible do |dir|
      dir.up do
        PhoneNumber.joins(
          active_plan: :incoming_phone_number
        ).where(incoming_phone_numbers: { account_type: "customer_managed" }).update_all(visibility: :public)
        PhoneNumber.where(enabled: false).update_all(visibility: :disabled)
        PhoneNumber.where(visibility: nil).update_all(visibility: :private)
      end
    end

    change_column_null(:phone_numbers, :visibility, false)
    remove_column(:phone_numbers, :enabled, :boolean, default: true)
  end
end
