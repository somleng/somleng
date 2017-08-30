class CreateAwsSnsMessages < ActiveRecord::Migration[5.1]
  def change
    create_table(:aws_sns_messages, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.json   :headers, :null => false, :default => {}
      t.json   :payload, :null => false, :default => {}
      t.uuid   :aws_sns_message_id, :null => false
      t.string :type, :null => false
      t.timestamps
    end

    add_index(:aws_sns_messages, :aws_sns_message_id, :unique => true)
  end
end
