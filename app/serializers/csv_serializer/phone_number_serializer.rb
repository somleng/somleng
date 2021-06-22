module CSVSerializer
  class PhoneNumberSerializer < ResourceSerializer
    def attributes
      super.merge(
        "account_sid" => nil,
        "number" => nil
      )
    end

    def account_sid
      account_id
    end
  end
end
