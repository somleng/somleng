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
    SHA256Digest.new(value:) if value.present?
  end

  def serialize(value)
    value.is_a?(SHA256Digest) ? value.digest : SHA256Digest.new(value:).digest
  end

  def deserialize(value)
    SHA256Digest.new(digest: value)
  end
end
