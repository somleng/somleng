CountrySelect::FORMATS[:with_dialing_country_code] = lambda do |country|
  "#{country.iso_short_name} (#{country.country_code})"
end
