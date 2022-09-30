class AddMaxChannelsToSIPTrunks < ActiveRecord::Migration[7.0]
  def change
    add_column(:sip_trunks, :max_channels, :integer)
  end
end
