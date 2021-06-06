class OutboundSIPTrunkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  DIAL_STRING_PREFIX_FORMAT = /\A\d+\z/.freeze

  attribute :carrier
  attribute :outbound_sip_trunk, default: -> { OutboundSIPTrunk.new }
  attribute :name
  attribute :host
  attribute :dial_string_prefix
  attribute :trunk_prefix, :boolean, default: false

  delegate :persisted?, :id, to: :outbound_sip_trunk

  validates :name, presence: true
  validates :host, presence: true
  validates :dial_string_prefix, format: DIAL_STRING_PREFIX_FORMAT, allow_nil: true, allow_blank: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "OutboundSIPTrunk")
  end

  def self.initialize_with(outbound_sip_trunk)
    new(
      outbound_sip_trunk: outbound_sip_trunk,
      name: outbound_sip_trunk.name,
      host: outbound_sip_trunk.host,
      dial_string_prefix: outbound_sip_trunk.dial_string_prefix,
      trunk_prefix: outbound_sip_trunk.trunk_prefix
    )
  end

  def save
    return false if invalid?

    outbound_sip_trunk.attributes = {
      name: name,
      carrier: carrier,
      host: host.strip,
      dial_string_prefix: dial_string_prefix.presence,
      trunk_prefix: trunk_prefix
    }

    outbound_sip_trunk.save!
  end
end
