class DropAwsSnsMessages < ActiveRecord::Migration[6.0]
  def change
    drop_table :recordings, force: :cascade
    drop_table :aws_sns_messages, force: :cascade
  end
end
