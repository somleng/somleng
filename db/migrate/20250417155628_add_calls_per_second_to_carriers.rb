class AddCallsPerSecondToCarriers < ActiveRecord::Migration[7.2]
  def change
    add_column(:carriers, :calls_per_second, :integer, default: 0, null: false)
  end
end
