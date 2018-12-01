class SIPHost
  class_attribute :hosts, default: {}
  attr_accessor :ip_address

  def self.find(ip_address)
    return nil if ip_address.blank?

    hosts.fetch(ip_address) do
      hosts[ip_address] = new(ip_address)
    end
  end

  def initialize(ip_address)
    self.ip_address = ip_address
  end

  def international_dialing_code
    info.fetch("international_dialing_code")
  end

  private

  attr_writer :info

  def info
    @info ||= fetch_info
  end

  def fetch_info
    data = Geocoder.search(ip_address).first.data
    data["international_dialing_code"] = ISO3166::Country.new(data.fetch("country")).country_code
    data
  end
end
