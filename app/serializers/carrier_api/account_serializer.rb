module CarrierAPI
  class AccountSerializer < ResourceSerializer
    attributes :name, :metadata, :status, :type, :default_tts_provider

    attribute :auth_token, if: proc { |record| record.carrier_managed? }
  end
end
