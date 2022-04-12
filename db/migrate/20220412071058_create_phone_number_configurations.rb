class CreatePhoneNumberConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_number_configurations, id: :uuid do |t|
      t.references :phone_number, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :voice_url
      t.string :voice_method
      t.string :status_callback_url
      t.string :status_callback_method
      t.string :sip_domain

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        PhoneNumber.find_each do |phone_number|
          phone_number.create_configuration!(
            voice_url: phone_number.voice_url,
            voice_method: phone_number.voice_method,
            status_callback_url: phone_number.status_callback_url,
            status_callback_method: phone_number.status_callback_method,
            sip_domain: phone_number.sip_domain
          )
        end
      end
    end

    remove_column :phone_numbers, :voice_url, :string
    remove_column :phone_numbers, :voice_method, :string
    remove_column :phone_numbers, :status_callback_url, :string
    remove_column :phone_numbers, :status_callback_method, :string
    remove_column :phone_numbers, :sip_domain, :string
  end
end
