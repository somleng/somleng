class AddLockVersonAndAvailableChannelsToSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    add_column(:sip_trunks, :lock_version, :integer)
    add_column(:sip_trunks, :last_channel_allocated_at, :datetime)
  end
end
