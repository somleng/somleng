class CreateOutgoingCalls < ActiveRecord::Migration
  def change
    create_table(:outgoing_calls, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references :account, :type => :uuid, :null => false, :index => true, :foreign_key => true
      t.timestamps :null => false
    end
  end
end
