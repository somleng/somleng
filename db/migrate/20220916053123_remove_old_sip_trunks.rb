class RemoveOldSIPTrunks < ActiveRecord::Migration[7.0]
  class OutboundSIPTrunk < ActiveRecord::Base
  end

  class InboundSIPTrunk < ActiveRecord::Base
  end

  def change
    reversible do |dir|
      dir.up do
        ApplicationRecord.transaction do
          migrate_sip_trunks
        end
      end
    end

    remove_column :phone_calls, :outbound_sip_trunk_id, :uuid
    remove_column :phone_calls, :inbound_sip_trunk_id, :uuid
    remove_column :accounts, :outbound_sip_trunk_id, :uuid

    reversible do |dir|
      dir.up do
        drop_table :outbound_sip_trunks
        drop_table :inbound_sip_trunks
      end
    end
  end

  private

  def migrate_sip_trunks
    existing_sip_trunks.each do |existing_sip_trunk|
      sip_trunk = SIPTrunk.new(
        carrier_id: existing_sip_trunk.carrier_id,
        name: existing_sip_trunk.name,
        created_at: existing_sip_trunk.created_at,
        updated_at: existing_sip_trunk.updated_at
      )

      if existing_sip_trunk.is_a?(OutboundSIPTrunk)
        sip_trunk.outbound_host = existing_sip_trunk.host
        sip_trunk.route_prefixes = existing_sip_trunk.route_prefixes
        sip_trunk.trunk_prefix = existing_sip_trunk.trunk_prefix
        sip_trunk.plus_prefix = existing_sip_trunk.plus_prefix
        sip_trunk.symmetric_latching_supported = existing_sip_trunk.nat_supported
      elsif existing_sip_trunk.is_a?(InboundSIPTrunk)
        sip_trunk.trunk_prefix_replacement = existing_sip_trunk.trunk_prefix_replacement
        sip_trunk.inbound_source_ip = existing_sip_trunk.source_ip
      end

      sip_trunk.save!

      PhoneCall.where(
        outbound_sip_trunk_id: existing_sip_trunk.id
      ).or(PhoneCall.where(inbound_sip_trunk_id: existing_sip_trunk.id)).update_all(
        sip_trunk_id: sip_trunk.id
      )

      Account.where(
        outbound_sip_trunk_id: existing_sip_trunk.id
      ).update_all(
        sip_trunk_id: sip_trunk.id
      )
    end
  end

  def existing_sip_trunks
    outbound_sip_trunks = OutboundSIPTrunk.all
    inbound_sip_trunks = InboundSIPTrunk.all

    existing_sip_trunks = outbound_sip_trunks + inbound_sip_trunks
    existing_sip_trunks.sort_by(&:created_at)
  end
end
