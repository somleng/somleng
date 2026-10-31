require "resolv"

class SIPTrunkForm < ApplicationForm
  DIAL_STRING_PREFIX_FORMAT = /\A\d+\z/
  COUNTRIES = ISO3166::Country.all.map(&:alpha2).freeze
  CALLER_ID_BEHAVIOR_HINTS = {
    passthrough: "Uses the caller ID provided in the incoming request.",
    fallback: "Uses the SIP Trunk's caller ID if none is provided (e.g., calls originating from the Verify API).",
    override: "Always replaces the incoming caller ID with the SIP Trunk's caller ID, ignoring any provided value."
  }.freeze

  attribute :carrier
  attribute :sip_trunk, default: -> { SIPTrunk.new }
  attribute :name
  attribute :max_channels
  attribute :authentication_mode
  attribute :route_prefixes, RoutePrefixesType.new, default: []
  attribute :region, RegionType.new
  attribute :caller_id, PhoneNumberType.new(preserve_plus_prefix: true)

  attribute :country
  attribute :source_ip_addresses, CommaSeparatedListType.new, default: []

  attribute :host
  attribute :dial_string_prefix
  attribute :national_dialing, :boolean, default: false
  attribute :plus_prefix, :boolean, default: false

  enumerize :authentication_mode, in: SIPTrunk.authentication_mode.values
  enumerize :caller_id_behavior,
            in: SIPTrunk.caller_id_behavior.values,
            default: :passthrough,
            predicates: { prefix: true }

  validates :name, :region, presence: true
  validates :max_channels, numericality: { greater_than: 0 }, allow_blank: true
  validates :authentication_mode, presence: true
  validates :country, inclusion: { in: COUNTRIES }, allow_blank: true
  validates :dial_string_prefix, format: DIAL_STRING_PREFIX_FORMAT, allow_blank: true
  validates :caller_id,
            presence: { unless: :caller_id_behavior_passthrough? },
            absence: { if: :caller_id_behavior_passthrough? }

  validate :validate_source_ip_addresses

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
      region: sip_trunk.region,
      source_ip_addresses: sip_trunk.inbound_source_ips,
      host: sip_trunk.outbound_host,
      dial_string_prefix: sip_trunk.outbound_dial_string_prefix,
      national_dialing: sip_trunk.outbound_national_dialing,
      plus_prefix: sip_trunk.outbound_plus_prefix,
      route_prefixes: sip_trunk.outbound_route_prefixes,
      caller_id: sip_trunk.caller_id.presence,
      caller_id_behavior: sip_trunk.caller_id_behavior
    )
  end

  def save
    return false if invalid?

    if authentication_mode.client_credentials?
      self.source_ip_addresses = nil
      self.host = nil
    end

    sip_trunk.attributes = {
      carrier:,
      authentication_mode:,
      name:,
      max_channels:,
      region:,
      inbound_source_ips: source_ip_addresses,
      inbound_country_code: country.presence,
      outbound_host: host.to_s.strip.presence,
      outbound_dial_string_prefix: dial_string_prefix.presence,
      outbound_national_dialing: national_dialing,
      outbound_plus_prefix: plus_prefix,
      outbound_route_prefixes: route_prefixes,
      caller_id:,
      caller_id_behavior:
    }

    sip_trunk.save!
  end

  def region_options_for_select
    SomlengRegion::Region.all.map do |region|
      [ region.human_name, region.alias, { data: { ip_address: region.nat_ip } } ]
    end
  end

  def caller_id_behavior_options_for_select
    self.class.caller_id_behavior.values.map do
      [
        "#{it.text} <div class='form-text'>#{CALLER_ID_BEHAVIOR_HINTS.fetch(it.value.to_sym)}</div>".html_safe,
        it.value
      ]
    end
  end

  private

  def validate_source_ip_addresses
    Array(source_ip_addresses).each do |ip|
      return errors.add(:source_ip_addresses, :invalid) unless Resolv::IPv4::Regex.match?(ip)
    end
  end
end
