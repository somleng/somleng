class SIPTrunk < ApplicationRecord
  DIAL_STRING_FORMAT = "%<plus_prefix>s%<dial_string_prefix>s%<national_prefix>s%<local_number>s@%<host>s".freeze

  include SIPTrunks::InboundSourceIPCallbacks
  include SIPTrunks::ClientCredentialsCallbacks

  extend Enumerize

  belongs_to :carrier
  encrypts :password

  enumerize :authentication_mode, in: %i[ip_address client_credentials]
  attribute :call_service_client, default: CallService::Client.new

  def outbound_example_dial_string
    return if outbound_host.blank?

    format(
      DIAL_STRING_FORMAT,
      plus_prefix: outbound_plus_prefix? ? "+" : "",
      dial_string_prefix: outbound_dial_string_prefix,
      national_prefix: outbound_trunk_prefix? ? "0" : "X" * carrier.country.country_code.to_s.length,
      local_number: "X" * carrier.country.national_number_lengths.last,
      host: outbound_host
    )
  end

  def configured_for_outbound_dialing?
    outbound_host.present?
  end
end
