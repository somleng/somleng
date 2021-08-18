module CarrierAPI
  class ResourceSerializer < JSONAPISerializer
    timestamp_attributes :created_at, :updated_at
  end
end
