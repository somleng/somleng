class CreateRecordings < ActiveRecord::Migration[5.1]
  def change
    create_table(:recordings, :id => :uuid, :default => "gen_random_uuid()") do |t|
      t.references(:phone_call, :null => false, :type => :uuid, :index => true, :foreign_key => true)
      t.string     :file_id
      t.string     :file_filename
      t.integer    :file_size
      t.string     :file_content_type
      t.integer    :duration
      t.uuid       :original_file_id
      t.string     :status, :null => false
      t.json       :twiml_instructions, :null => false, :default => {}
      t.json       :params, :null => false, :default => {}
      t.timestamps
    end

    add_index(:recordings, :original_file_id, :unique => true)
  end
end
