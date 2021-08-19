class JSONAPISerializer
  include JSONAPI::Serializer

  def self.timestamp_attributes(*names)
    names.each do |name|
      attribute(name) do |object|
        object.public_send(name).utc.iso8601 if object.public_send(name).present?
      end
    end
  end
end
