class DNSResolver
  def resolve?(host:, record_value:)
    Resolv::DNS.open do |dns|
      records = dns.getresources(host, Resolv::DNS::Resource::IN::TXT)
      records.any? { |record| record.data == record_value }
    end
  end
end
