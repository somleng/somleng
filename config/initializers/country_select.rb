CountrySelect::FORMATS[:with_dialing_country_code] = lambda do |country|
  "#{country.iso_short_name} (#{country.common_name})"
end

CountrySelect::FORMATS[:with_flag] = lambda do |country|
  "#{country.emoji_flag} #{country.common_name}"
end
