module CarrierAPI
  class EventSerializer < ResourceSerializer
    attributes :type, :details
  end
end
