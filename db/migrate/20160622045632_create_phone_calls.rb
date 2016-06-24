class CreatePhoneCalls < ActiveRecord::Migration
  def change
    create_table(:phone_calls, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references :account, :type => :uuid, :null => false, :index => true, :foreign_key => true
      t.string     :to,                      :null => false
      t.string     :from,                    :null => false
      t.string     :voice_url,               :null => false
      t.string     :voice_method,            :null => false
      t.string     :status,                  :null => false
      t.string     :status_callback_url
      t.string     :status_callback_method
      t.timestamps                           :null => false
    end
  end
end
