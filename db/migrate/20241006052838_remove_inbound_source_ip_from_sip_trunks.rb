class RemoveInboundSourceIPFromSIPTrunks < ActiveRecord::Migration[7.2]
  def change
    remove_column(:sip_trunks, :inbound_source_ip, :inet)
  end
end
