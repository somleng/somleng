require "digest"

class SHA256Type < ActiveRecord::Type::String
  SHA256Digest = Struct.new(:value, :digest, keyword_init: true) do
    def initialize(value: nil, digest: nil)
      super
      self.digest ||= Digest::SHA256.hexdigest(value)
    end

    def to_s
      digest
    end
  end

  def cast(value)
    return if value.blank?

    value.is_a?(SHA256Digest) ? value : SHA256Digest.new(value:)
  end

  def serialize(value)
    cast(value)&.digest
  end

  def deserialize(value)
    SHA256Digest.new(digest: value) if value.present?
  end
end
