module Services
  class AudioStreamSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "url" => nil
      )
    end
  end
end
