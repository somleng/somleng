class RemoveInboundSourceIPFromSIPTrunks < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        SIPTrunk.where.not(inbound_source_ip: nil).find_each do |sip_trunk|
          sip_trunk.inbound_source_ip_addresses.create_or_find_by!(source_ip: sip_trunk.inbound_source_ip)
        end

        remove_column(:sip_trunks, :inbound_source_ip, :inet)
      end

      dir.down do
        add_column(:sip_trunks, :inbound_source_ip, :inet)
        SIPTrunkInboundSourceIPAddress.includes(:sip_trunk, :inbound_source_ip_address).find_each do |sip_trunk_inbound_source_ip|
          sip_trunk = sip_trunk_inbound_source_ip.sip_trunk
          inbound_source_ip = sip_trunk_inbound_source_ip.inbound_source_ip_address.source_ip
          sip_trunk.update_columns(inbound_source_ip:)
        end
      end
    end
  end
end
