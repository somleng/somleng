class AddTwimlToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :phone_calls, :twiml, :text
    change_column_null :phone_calls, :voice_url, true
    change_column_null :phone_calls, :voice_method, true
  end
end
