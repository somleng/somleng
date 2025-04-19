class AddRegionToPhoneCalls < ActiveRecord::Migration[7.2]
  def change
    add_column(:phone_calls, :region, :string)
  end
end
