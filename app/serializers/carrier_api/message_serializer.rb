module CarrierAPI
  class MessageSerializer < ResourceSerializer
    attributes :to, :from, :price, :price_unit, :direction, :status, :body

    belongs_to :account
  end
end
