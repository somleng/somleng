class InboundSIPTrunkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :inbound_sip_trunk, default: -> { InboundSIPTrunk.new }
  attribute :name
  attribute :source_ip
  attribute :trunk_prefix_replacement

  delegate :persisted?, :id, to: :inbound_sip_trunk

  validates :name, :source_ip, presence: true
  validates :source_ip, format: Resolv::IPv4::Regex
  validate :validate_source_ip

  def self.model_name
    ActiveModel::Name.new(self, nil, "InboundSIPTrunk")
  end

  def self.initialize_with(inbound_sip_trunk)
    new(
      inbound_sip_trunk: inbound_sip_trunk,
      name: inbound_sip_trunk.name,
      source_ip: inbound_sip_trunk.source_ip,
      trunk_prefix_replacement: inbound_sip_trunk.trunk_prefix_replacement
    )
  end

  def save
    return false if invalid?

    inbound_sip_trunk.attributes = {
      name: name,
      carrier: carrier,
      source_ip: source_ip,
      trunk_prefix_replacement: trunk_prefix_replacement.presence
    }

    inbound_sip_trunk.save!
  end

  private

  def validate_source_ip
    return if errors[:source_ip].any?
    return if inbound_sip_trunk.source_ip == source_ip
    return unless InboundSIPTrunk.exists?(source_ip: source_ip)

    errors.add(:source_ip, :taken)
  end
end
