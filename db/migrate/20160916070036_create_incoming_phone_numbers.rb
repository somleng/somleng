class CreateIncomingPhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table(:incoming_phone_numbers, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references :account, :type => :uuid, :null => false, :index => true, :foreign_key => true
      t.string     :phone_number,            :null => false
      t.string     :voice_url,               :null => false
      t.string     :voice_method,            :null => false
      t.string     :status_callback_url
      t.string     :status_callback_method
      t.timestamps
    end

    add_index(:incoming_phone_numbers, :phone_number, :unique => true)
  end
end
