module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    attributes :number, :country, :visibility, :type, :locality, :metadata

    attribute :currency do |object|
      object.currency.iso_code
    end

    attribute :price do |object|
      object.price.to_s
    end

    attribute :country do |object|
      object.iso_country_code
    end

    attribute :region do |object|
      object.iso_region_code
    end
  end
end
