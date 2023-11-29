module CSVSerializer
  class TTSEventSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "phone_call_sid" => nil,
        "voice" => nil,
        "characters" => nil
      )
    end
  end
end
