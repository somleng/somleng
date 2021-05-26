module CSVSerializer
  class AccountSerializer < ResourceSerializer
    def attributes
      super.merge(
        "name" => nil,
        "status" => nil,
        "type" => nil
      )
    end

    def status
      super.humanize
    end

    def type
      super.humanize
    end
  end
end
