class InboundSIPTrunkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :inbound_sip_trunk, default: -> { InboundSIPTrunk.new }
  attribute :name
  attribute :source_ip

  delegate :persisted?, :id, to: :inbound_sip_trunk

  validates :name, :source_ip, presence: true
  validates :source_ip, format: Resolv::IPv4::Regex

  def self.model_name
    ActiveModel::Name.new(self, nil, "InboundSIPTrunk")
  end

  def self.initialize_with(inbound_sip_trunk)
    new(
      inbound_sip_trunk: inbound_sip_trunk,
      name: inbound_sip_trunk.name,
      source_ip: inbound_sip_trunk.source_ip
    )
  end

  def save
    return false if invalid?

    inbound_sip_trunk.attributes = {
      name: name,
      carrier: carrier,
      source_ip: source_ip
    }

    inbound_sip_trunk.save!
  end
end
