class AddCarrierIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference(:accounts, :carrier, type: :uuid, foreign_key: true)
    add_reference(:accounts, :outbound_sip_trunk, type: :uuid, foreign_key: true)
    add_column(:accounts, :allowed_calling_codes, :string, null: false, array: true, default: [])
    rename_column(:accounts, :state, :status)

    reversible do |dir|
      dir.up do
        migrate_data if Rails.env.production?
      end
    end

    change_column_null(:accounts, :carrier_id, false)
  end

  private

  def migrate_data
    somleng_carrier = Carrier.create!(name: "Somleng")
    c3ntro_carrier = Carrier.create!(name: "C3NTRO Telecom")

    OutboundSIPTrunk.create!(
      name: "Metfone",
      host: "175.100.32.29",
      route_prefixes: (Torasup::Operator.all["kh"]["metfone"]["landline_prefixes"].keys + Torasup::Operator.all["kh"]["metfone"]["mobile_prefixes"].keys).sort_by { |p| [p.length, p] },
      trunk_prefix: true,
      carrier: somleng_carrier
    )
    OutboundSIPTrunk.create!(
      name: "Cellcard",
      host: "103.193.204.26",
      route_prefixes: (Torasup::Operator.all["kh"]["mobitel"]["landline_prefixes"].keys + Torasup::Operator.all["kh"]["mobitel"]["mobile_prefixes"].keys).sort_by { |p| [p.length, p] },
      trunk_prefix: true,
      carrier: somleng_carrier
    )
    OutboundSIPTrunk.create!(
      name: "Smart",
      host: "27.109.112.140",
      route_prefixes: (Torasup::Operator.all["kh"]["smart"]["landline_prefixes"].keys + Torasup::Operator.all["kh"]["smart"]["mobile_prefixes"].keys).sort_by { |p| [p.length, p] },
      trunk_prefix: true,
      carrier: somleng_carrier
    )

    [somleng_carrier, c3ntro_carrier].each do |carrier|
      OutboundSIPTrunk.create!(
        name: "C3NTRO Default",
        host: "200.0.90.35",
        dial_string_prefix: "69980",
        carrier: carrier
      )
    end

    somleng_test_account = Account.find("991516bf-7b03-4ce6-914f-497e40f5bbe8")
    somleng_test_account.update!(carrier: somleng_carrier)

    c3ntro_account = Account.find("8b73164a-91d1-46c6-b984-6137b69e7541")
    unicef_guatemala_account = Account.find("f3b848d3-186f-401a-b889-bcb5a85a90a6")

    c3ntro_account.update!(carrier: c3ntro_carrier)
    unicef_guatemala_account.update!(carrier: c3ntro_carrier)

    pin_account = Account.find("36686827-9b14-4073-bcd0-bda9ec8d60bd")
    pin_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["855"])

    africas_voices_account = Account.find("c571c953-9626-4314-84ea-d641c3869cfc")
    africas_voices_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["252"], status: :disabled)

    ilhasoft_account = Account.find("a22be00f-18ab-44a0-8733-c1de07045ee9")
    ilhasoft_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["55"], status: :disabled)

    unicef_sierra_leone_account = Account.find("2d72f796-b52e-4cbb-8fdd-682f53d39e3c")
    unicef_sierra_leone_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["232"], status: :disabled)

    unicef_india_account = Account.find("bed4d640-0a82-41a7-829d-e122f4c1d1c4")
    unicef_india_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["91"], status: :disabled)

    neo_assist_account = Account.find("d0957e11-f5de-4ad1-af4f-a9c6af7828a1")
    neo_assist_account.update!(carrier: somleng_carrier, allowed_calling_codes: ["55"], status: :disabled)
  end
end
