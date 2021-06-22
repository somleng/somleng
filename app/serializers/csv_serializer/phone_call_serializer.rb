module CSVSerializer
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "status" => nil
      )
    end

    def sid
      id
    end

    def account_sid
      account_id
    end
  end
end
