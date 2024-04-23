module CSVSerializer
  class PhoneNumberPlanSerializer < ResourceSerializer
    def attributes
      super.merge(
        "account_sid" => nil,
        "number" => nil,
        "status" => nil,
        "canceled_at" => nil,
        "amount" => nil,
        "currency" => nil
      )
    end

    def account_sid
      account_id
    end
  end
end
