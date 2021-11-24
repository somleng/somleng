module CarrierAPI
  class PhoneCallSerializer < ResourceSerializer
    attributes :to, :from, :price, :price_unit, :direction
  end
end
