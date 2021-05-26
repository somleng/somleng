module CSVSerializer
  class UserSerializer < ResourceSerializer
    def attributes
      super.merge(
        "name" => nil,
        "email" => nil,
        "role" => nil
      )
    end

    def role
      super.humanize
    end
  end
end
