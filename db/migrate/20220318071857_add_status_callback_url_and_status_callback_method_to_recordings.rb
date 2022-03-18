class AddStatusCallbackUrlAndStatusCallbackMethodToRecordings < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings do |t|
      t.text :status_callback_url
      t.string :status_callback_method
    end
  end
end
