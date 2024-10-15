class RemoveInboundSourceIPFromSIPTrunks < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        SIPTrunk.where.not(inbound_source_ip: nil).find_each do |sip_trunk|
          sip_trunk.inbound_source_ips = sip_trunk.inbound_source_ip
          sip_trunk.save!
        end

        raise unless InboundSourceIPAddress.count == SIPTrunk.pluck(:inbound_source_ip).count

        remove_column(:sip_trunks, :inbound_source_ip, :inet)
      end

      dir.down do
        add_column(:sip_trunks, :inbound_source_ip, :inet)

        SIPTrunk.joins(:sip_trunk_inbound_source_ip_addresses).find_each do |sip_trunk|
          sip_trunk_inbound_source_ip_address = sip_trunk.sip_trunk_inbound_source_ip_addresses.first
          sip_trunk.update_columns(inbound_source_ip: sip_trunk_inbound_source_ip_address.ip)
        end
      end
    end
  end
end
