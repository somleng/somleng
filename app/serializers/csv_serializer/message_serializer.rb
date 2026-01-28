module CSVSerializer
  class MessageSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "phone_number_sid" => nil,
        "from" => nil,
        "to" => nil,
        "price" => nil,
        "price_unit" => nil,
        "direction" => nil,
        "status" => nil
      )
    end

    private

    def price
      object.price_formatted
    end
  end
end
