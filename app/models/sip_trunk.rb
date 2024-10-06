class SIPTrunk < ApplicationRecord
  DIAL_STRING_FORMAT = "%<plus_prefix>s%<dial_string_prefix>s%<national_prefix>s%<local_number>s@%<host>s".freeze

  extend Enumerize

  has_many :phone_calls
  has_many :sip_trunk_inbound_source_ip_addresses
  has_many :inbound_source_ip_addresses, through: :sip_trunk_inbound_source_ip_addresses
  belongs_to :carrier
  encrypts :password

  enumerize :authentication_mode, in: %i[ip_address client_credentials]

  attribute :username_generator, default: UsernameGenerator.new
  attribute :region, RegionType.new
  attribute :default_sender, PhoneNumberType.new

  before_save :generate_client_credentials

  def inbound_country
    ISO3166::Country.new(inbound_country_code) if inbound_country_code.present?
  end

  def outbound_example_dial_string
    format(
      DIAL_STRING_FORMAT,
      plus_prefix: outbound_plus_prefix? ? "+" : "",
      dial_string_prefix: outbound_dial_string_prefix,
      national_prefix: outbound_national_dialing? ? carrier.country.national_prefix : "X" * carrier.country.country_code.to_s.length,
      local_number: "X" * carrier.country.national_number_lengths.last,
      host: outbound_host.present? ? outbound_host : "your-sip-registration-ip"
    )
  end

  def configured_for_outbound_dialing?
    authentication_mode.client_credentials? || outbound_host.present?
  end

  private

  def generate_client_credentials
    if authentication_mode.client_credentials?
      return if username.present?

      self.username = generate_username
      self.password = SecureRandom.alphanumeric(24)
    else
      self.username = nil
      self.password = nil
    end
  end

  def generate_username
    10.times do
      username = username_generator.random_username
      return username unless self.class.exists?(username:)
    end

    raise "Unable to generate unique username"
  end
end
