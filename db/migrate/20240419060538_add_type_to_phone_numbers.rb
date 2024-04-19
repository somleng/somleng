class AddTypeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :type, :string)
    add_index(:phone_numbers, :type)
  end
end
