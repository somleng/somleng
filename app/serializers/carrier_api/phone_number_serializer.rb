module CarrierAPI
  class PhoneNumberSerializer < ResourceSerializer
    belongs_to :account, if: ->(record, _params) { record.account_id.present? }

    attributes :number, :voice_url, :voice_method, :status_callback_url, :status_callback_method
  end
end
