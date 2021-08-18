module CarrierAPI
  class AccountSerializer < ResourceSerializer
    attributes :name, :metadata, :status
  end
end
