module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    belongs_to :account, if: ->(record, _params) { record.account_id.present? }

    attributes :number, :country, :enabled, :type

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
