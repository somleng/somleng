module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    belongs_to :account, if: ->(record, _params) { record.account_id.present? }

    attributes :number, :enabled
  end
end
