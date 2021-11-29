module CarrierAPI
  class PhoneCallSerializer < ResourceSerializer
    attributes :to, :from, :sid, :account_sid, :price, :price_unit, :duration, :direction, :status
  end
end
