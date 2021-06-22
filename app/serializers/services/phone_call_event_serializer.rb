module Services
  class PhoneCallEventSerializer < ResourceSerializer
    def attributes
      super.merge(
        "type" => nil
      )
    end
  end
end
