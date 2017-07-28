class CreatePhoneCallEvents < ActiveRecord::Migration[5.0]
  def change
    create_table(:phone_call_events, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references(:phone_call, :null => false, :type => :uuid, :index => true, :foreign_key => true)
      t.json   :params, :null => false, :default => {}
      t.string :type, :null => false
      t.timestamps
    end
  end
end
