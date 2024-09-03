class SIPTrunk < ApplicationRecord
  DIAL_STRING_FORMAT = "%<plus_prefix>s%<dial_string_prefix>s%<national_prefix>s%<local_number>s@%<host>s".freeze

  extend Enumerize

  has_many :phone_calls
  belongs_to :default_sender, class_name: "PhoneNumber", optional: true
  belongs_to :carrier
  encrypts :password

  enumerize :authentication_mode, in: %i[ip_address client_credentials]

  attribute :call_service_client, default: CallService::Client.new
  attribute :username_generator, default: UsernameGenerator.new
  attribute :region, RegionType.new

  before_save :generate_client_credentials
  after_create :create_subscriber
  after_destroy :delete_subscriber
  after_update :update_subscriber

  after_create :authorize_inbound_source_ip
  after_destroy :revoke_inbound_source_ip
  after_update :update_inbound_source_ip, :update_region

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

  def create_subscriber
    return if username.blank?

    call_service_client.create_subscriber(username:, password:)
  end

  def delete_subscriber(username_to_delete: username)
    return if username_to_delete.blank?

    call_service_client.delete_subscriber(username: username_to_delete)
  end

  def update_subscriber
    old_username, new_username = previous_changes[:username]

    return if old_username == new_username

    delete_subscriber(username_to_delete: old_username)
    create_subscriber
  end

  def authorize_inbound_source_ip
    return if inbound_source_ip.blank?

    call_service_client.add_permission(inbound_source_ip, group_id: region.group_id)
  end

  def revoke_inbound_source_ip(ip: inbound_source_ip)
    return if ip.blank?

    call_service_client.remove_permission(ip)
  end

  def update_inbound_source_ip
    old_inbound_source_ip, new_inbound_source_ip = previous_changes[:inbound_source_ip]

    return if old_inbound_source_ip == new_inbound_source_ip

    revoke_inbound_source_ip(ip: old_inbound_source_ip)
    authorize_inbound_source_ip
  end

  def update_region
    old_region, new_region = previous_changes[:region]

    return if old_region == new_region

    revoke_inbound_source_ip(ip: inbound_source_ip)
    authorize_inbound_source_ip
  end
end
