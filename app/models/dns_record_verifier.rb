require "resolv"

class DNSRecordVerifier
  attr_reader :host, :record_value

  def initialize(host:, record_value:)
    @host = host
    @record_value = record_value
  end

  def verify
    Resolv::DNS.open do |dns|
      records = dns.getresources(host, Resolv::DNS::Resource::IN::TXT)
      records.any? { |record| record.data == record_value }
    end
  end
end
