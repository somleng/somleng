module Services
  class MediaStreamSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "url" => nil
      )
    end
  end
end
