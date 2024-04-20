module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    belongs_to :account, if: ->(record, _params) { record.account_id.present? }

    attributes :number, :country, :enabled

    attribute :country do |object|
      object.iso_country_code
    end
  end
end
