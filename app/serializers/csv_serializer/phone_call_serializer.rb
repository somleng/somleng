module CSVSerializer
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "phone_number_sid" => nil,
        "from" => nil,
        "to" => nil,
        "duration" => nil,
        "direction" => nil,
        "status" => nil
      )
    end

    def sid
      id
    end

    def duration
      super.to_i
    end

    def account_sid
      account_id
    end

    def phone_number_sid
      phone_number_id
    end

    def from
      format_number(super, spaces: "")
    end

    def to
      format_number(super, spaces: "")
    end
  end
end
