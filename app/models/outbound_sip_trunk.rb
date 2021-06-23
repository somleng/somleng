class OutboundSIPTrunk < ApplicationRecord
  belongs_to :carrier

  def example_dial_string
    format(
      "%{dial_string_prefix}%{national_prefix}%{local_number}@%{host}",
      dial_string_prefix: dial_string_prefix,
      national_prefix: trunk_prefix? ? "0" : "X" * carrier.country.country_code.to_s.length,
      local_number: "X" * carrier.country.national_number_lengths.last,
      host: host
    )
  end
end
