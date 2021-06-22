module CSVSerializer
  class AccountSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "name" => nil,
        "status" => nil
      )
    end

    def sid
      id
    end

    def status
      super.humanize
    end
  end
end
