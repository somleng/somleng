module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    attributes :number, :country, :visibility, :type

    attribute :currency do |object|
      object.currency.iso_code
    end

    attribute :price do |object|
      object.price.to_s
    end

    attribute :country do |object|
      object.iso_country_code
    end
  end
end
