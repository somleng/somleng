module Services
  class PhoneCallEventSerializer < ResourceSerializer
    def serializable_hash(_options = nil)
      super.merge(
        type: object.type
      )
    end
  end
end
