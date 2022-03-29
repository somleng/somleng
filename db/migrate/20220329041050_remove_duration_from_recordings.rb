class RemoveDurationFromRecordings < ActiveRecord::Migration[7.0]
  def change
    remove_column(:recordings, :duration, :integer)
  end
end
