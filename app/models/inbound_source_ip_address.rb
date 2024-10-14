class InboundSourceIPAddress < ApplicationRecord
  has_many :sip_trunk_inbound_source_ip_addresses
  has_many :sip_trunks, through: :sip_trunk_inbound_source_ip_addresses
  has_many :carriers, through: :sip_trunks

  validates :ip, :region, presence: true

  attribute :region, RegionType.new
  attribute :call_service_client, default: -> { CallService::Client.new }

  after_create :add_permission
  after_destroy :remove_permission

  class << self
    def unused
      where.not(id: in_use.select(:id))
    end

    def in_use
      joins(:sip_trunk_inbound_source_ip_addresses)
    end
  end

  private

  def add_permission
    call_service_client.add_permission(ip, group_id: region.group_id)
  end

  def remove_permission
    call_service_client.remove_permission(ip)
  end
end
