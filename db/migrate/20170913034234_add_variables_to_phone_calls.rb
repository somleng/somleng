class AddVariablesToPhoneCalls < ActiveRecord::Migration[5.1]
  def change
    add_column(:phone_calls, :variables, :json, :null => false, :default => {})
  end
end
