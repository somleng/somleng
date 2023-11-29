module CarrierAPI
  class PhoneCallSerializer < ResourceSerializer
    attributes :to, :from, :price, :price_unit, :duration, :direction, :status

    belongs_to :account
  end
end
