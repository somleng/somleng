class RenameSIPTrunkColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column(:sip_trunks, :outbound_trunk_prefix, :outbound_national_dialing)
    add_column(:sip_trunks, :inbound_country_code, :string)

    reversible do |dir|
      dir.up do
        SIPTrunk.where.not(inbound_trunk_prefix_replacement: nil).find_each do |sip_trunk|
          country = ISO3166::Country.find_country_by_country_code(
            sip_trunk.inbound_trunk_prefix_replacement
          )
          next if country.blank?

          sip_trunk.update_columns(inbound_country_code: country.alpha2)
        end
      end
    end

    remove_column(:sip_trunks, :inbound_trunk_prefix_replacement, :string)
  end
end
