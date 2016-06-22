class CreateAccounts < ActiveRecord::Migration
  def change
    enable_extension('pgcrypto')
    create_table(:accounts, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.timestamps(:null => false)
    end
  end
end
