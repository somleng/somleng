class IPAddressArrayType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    Array(value).select { |ip| ip.is_a?(IPAddr) || Resolv::IPv4::Regex.match?(ip) }.uniq
  end
end
