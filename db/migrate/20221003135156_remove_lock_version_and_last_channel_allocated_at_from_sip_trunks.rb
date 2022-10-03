class RemoveLockVersionAndLastChannelAllocatedAtFromSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    remove_column(:sip_trunks, :lock_version, :integer)
    remove_column(:sip_trunks, :last_channel_allocated_at, :datetime)
  end
end
