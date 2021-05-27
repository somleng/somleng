module CSVSerializer
  class AccountSerializer < ResourceSerializer
    def attributes
      super.merge(
        "name" => nil,
        "status" => nil,
      )
    end

    def status
      super.humanize
    end
  end
end
