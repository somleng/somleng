class AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :account, default: -> { Account.new(access_token: Doorkeeper::AccessToken.new) }
  attribute :outbound_sip_trunk_id

  delegate :persisted?, :id, to: :account

  validates :name, presence: true, unless: :persisted?

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(account)
    new(
      account: account,
      carrier: account.carrier,
      name: account.name,
      outbound_sip_trunk_id: account.outbound_sip_trunk_id,
      enabled: account.enabled?
    )
  end

  def save
    return false if invalid?

    account.attributes = {
      carrier: carrier,
      status: enabled ? "enabled" : "disabled"
    }
    account.name = name if name.present?
    if outbound_sip_trunk_id.present?
      account.outbound_sip_trunk = carrier.outbound_sip_trunks.find(outbound_sip_trunk_id)
    end

    account.save!
  end

  def outbound_sip_trunk_options_for_select
    carrier.outbound_sip_trunks.map do |outbound_sip_trunk|
      {
        id: outbound_sip_trunk.id,
        text: outbound_sip_trunk.name
      }
    end
  end
end
