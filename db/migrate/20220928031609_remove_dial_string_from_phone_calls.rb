class RemoveDialStringFromPhoneCalls < ActiveRecord::Migration[7.0]
  def change
    remove_column(:phone_calls, :dial_string, :string)
  end
end
