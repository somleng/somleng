class AddVisibilityToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :visibility, :string, null: false)
    add_index(:phone_numbers, :visibility)
    remove_column(:phone_numbers, :enabled, :boolean, default: true)
  end
end
