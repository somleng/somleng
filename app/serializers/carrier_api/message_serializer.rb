module CarrierAPI
  class MessageSerializer < ResourceSerializer
    attributes :to, :from, :sid, :account_sid, :price, :price_unit, :direction, :status, :body
  end
end
