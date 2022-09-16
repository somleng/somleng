require "resolv"

class SIPTrunkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  DIAL_STRING_PREFIX_FORMAT = /\A\d+\z/.freeze

  attribute :carrier
  attribute :sip_trunk, default: -> { SIPTrunk.new }
  attribute :name
  attribute :source_ip
  attribute :trunk_prefix_replacement

  attribute :host
  attribute :dial_string_prefix
  attribute :trunk_prefix, :boolean, default: false
  attribute :plus_prefix, :boolean, default: false

  delegate :persisted?, :id, to: :sip_trunk

  validates :name, presence: true
  validates :source_ip, format: Resolv::IPv4::Regex, allow_blank: true
  validate :validate_source_ip

  validates :name, presence: true
  validates :dial_string_prefix, format: DIAL_STRING_PREFIX_FORMAT, allow_blank: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "SIPTrunk")
  end

  def self.initialize_with(sip_trunk)
    new(
      sip_trunk:,
      name: sip_trunk.name,
      source_ip: sip_trunk.inbound_source_ip.presence,
      trunk_prefix_replacement: sip_trunk.inbound_trunk_prefix_replacement,
      host: sip_trunk.outbound_host,
      dial_string_prefix: sip_trunk.outbound_dial_string_prefix,
      trunk_prefix: sip_trunk.outbound_trunk_prefix,
      plus_prefix: sip_trunk.outbound_plus_prefix
    )
  end

  def save
    return false if invalid?

    sip_trunk.attributes = {
      name:,
      carrier:,
      inbound_source_ip: source_ip,
      inbound_trunk_prefix_replacement: trunk_prefix_replacement.presence,
      outbound_host: host.strip,
      outbound_dial_string_prefix: dial_string_prefix.presence,
      outbound_trunk_prefix: trunk_prefix,
      outbound_plus_prefix: plus_prefix
    }

    sip_trunk.save!
  end

  private

  def validate_source_ip
    return if source_ip.blank?
    return if errors[:source_ip].any?
    return if sip_trunk.inbound_source_ip == source_ip
    return unless SIPTrunk.exists?(inbound_source_ip: source_ip)

    errors.add(:source_ip, :taken)
  end
end
