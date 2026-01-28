module CarrierAPI
  class PhoneCallSerializer < ResourceSerializer
    attributes :to, :from, :price_unit, :duration, :direction, :status

    belongs_to :account

    attribute :price do |object|
      object.price_formatted
    end
  end
end
