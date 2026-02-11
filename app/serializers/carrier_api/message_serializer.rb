module CarrierAPI
  class MessageSerializer < ResourceSerializer
    attributes :to, :from, :price_unit, :direction, :status, :body

    belongs_to :account

    attribute :price do |object|
      object.price_formatted
    end
  end
end
