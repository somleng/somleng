class AddMetadataToPhoneNumbers < ActiveRecord::Migration[7.2]
  def change
    add_column(:phone_numbers, :metadata, :jsonb, null: false, default: {})
    add_index(:phone_numbers, :metadata, using: :gin)
  end
end
