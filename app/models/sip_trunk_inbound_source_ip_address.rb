class SIPTrunkInboundSourceIPAddress < ApplicationRecord
  belongs_to :sip_trunk
  belongs_to :carrier
  belongs_to :inbound_source_ip_address

  attribute :region, RegionType.new

  validates :region, presence: true

  before_validation :set_carrier, :find_or_initialize_inbound_source_ip_address

  private

  def set_carrier
    self.carrier ||= sip_trunk.carrier
  end

  def find_or_initialize_inbound_source_ip_address
    self.inbound_source_ip_address ||= InboundSourceIPAddress.find_or_initialize_by(ip:) do |inbound_source_ip|
      inbound_source_ip.region ||= region
    end
  end
end
