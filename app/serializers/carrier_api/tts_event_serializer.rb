module CarrierAPI
  class TTSEventSerializer < ResourceSerializer
    belongs_to :account
    belongs_to :phone_call

    attributes :voice, :characters
  end
end
