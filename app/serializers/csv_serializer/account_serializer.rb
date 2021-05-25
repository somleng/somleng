module CSVSerializer
  class AccountSerializer < ResourceSerializer
    def serializable_hash(_options = nil)
      super.merge(
        name: object.name,
        status: object.status.humanize
      )
    end
  end
end
