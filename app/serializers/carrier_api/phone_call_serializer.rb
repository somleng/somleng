module CarrierAPI
  class PhoneCallSerializer < ResourceSerializer
    attributes :to, :from
  end
end
