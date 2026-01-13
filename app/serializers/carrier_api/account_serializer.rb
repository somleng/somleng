module CarrierAPI
  class AccountSerializer < ResourceSerializer
    attributes :name, :metadata, :status, :type, :billing_enabled, :billing_mode

    attribute :auth_token, if: proc { |record| record.carrier_managed? }

    attribute :default_tts_voice do |object|
      object.default_tts_voice.identifier
    end
  end
end
