require "resolv"

class SIPTrunkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  DIAL_STRING_PREFIX_FORMAT = /\A\d+\z/
  COUNTRIES = ISO3166::Country.all.map(&:alpha2).freeze

  attribute :carrier
  attribute :sip_trunk, default: -> { SIPTrunk.new }
  attribute :name
  attribute :max_channels
  attribute :authentication_mode
  attribute :route_prefixes, RoutePrefixesType.new
  attribute :region, RegionType.new

  attribute :country
  attribute :source_ip

  attribute :host
  attribute :dial_string_prefix
  attribute :national_dialing, :boolean, default: false
  attribute :plus_prefix, :boolean, default: false
  attribute :default_sender_id

  enumerize :authentication_mode, in: SIPTrunk.authentication_mode.values

  validates :name, :region, presence: true
  validates :max_channels, numericality: { greater_than: 0 }, allow_blank: true
  validates :authentication_mode, presence: true
  validates :country, inclusion: { in: COUNTRIES }, allow_blank: true
  validates :source_ip, format: Resolv::IPv4::Regex, allow_blank: true
  validate :validate_source_ip
  validates :dial_string_prefix, format: DIAL_STRING_PREFIX_FORMAT, allow_blank: true

  delegate :new_record?, :persisted?, :id, to: :sip_trunk

  def self.model_name
    ActiveModel::Name.new(self, nil, "SIPTrunk")
  end

  def self.initialize_with(sip_trunk)
    new(
      sip_trunk:,
      carrier: sip_trunk.carrier,
      authentication_mode: sip_trunk.authentication_mode,
      name: sip_trunk.name,
      max_channels: sip_trunk.max_channels,
      country: sip_trunk.inbound_country_code,
      source_ip: sip_trunk.inbound_source_ip.presence,
      host: sip_trunk.outbound_host,
      dial_string_prefix: sip_trunk.outbound_dial_string_prefix,
      national_dialing: sip_trunk.outbound_national_dialing,
      plus_prefix: sip_trunk.outbound_plus_prefix,
      route_prefixes: sip_trunk.outbound_route_prefixes,
      default_sender_id: sip_trunk.default_sender_id,
      region: sip_trunk.region
    )
  end

  def save
    return false if invalid?

    if authentication_mode.client_credentials?
      self.source_ip = nil
      self.host = nil
    end

    sip_trunk.attributes = {
      carrier:,
      authentication_mode:,
      name:,
      max_channels:,
      region:,
      inbound_source_ip: source_ip,
      inbound_country_code: country.presence,
      outbound_host: host.to_s.strip.presence,
      outbound_dial_string_prefix: dial_string_prefix.presence,
      outbound_national_dialing: national_dialing,
      outbound_plus_prefix: plus_prefix,
      outbound_route_prefixes: RoutePrefixesType.new.deserialize(route_prefixes),
      default_sender: default_sender_id.present? && default_sender_scope.find(default_sender_id)
    }

    sip_trunk.save!
  end

  def default_sender_options_for_select
    default_sender_scope.map do |phone_number|
      [ phone_number.decorated.number_formatted, phone_number.id ]
    end
  end

  def region_options_for_select
    SomlengRegion::Region.all.map do |region|
      [ region.human_name, region.alias, { data: { ip_address: region.nat_ip } } ]
    end
  end

  private

  def validate_source_ip
    return if source_ip.blank?
    return if errors[:source_ip].any?
    return if sip_trunk.inbound_source_ip == source_ip
    return unless SIPTrunk.exists?(inbound_source_ip: source_ip)

    errors.add(:source_ip, :taken)
  end

  def default_sender_scope
    carrier.phone_numbers.private.available.where(type: :alphanumeric_sender_id)
  end
end
