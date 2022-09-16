class SIPTrunk < ApplicationRecord
  include InboundSourceIPCallbacks

  belongs_to :carrier

  def outbound_example_dial_string
    return if outbound_host.blank?

    format(
      "%{plus_prefix}%{dial_string_prefix}%{national_prefix}%{local_number}@%{host}",
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
