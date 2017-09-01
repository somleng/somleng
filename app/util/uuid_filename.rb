class UUIDFilename
  UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  def self.uuid_from_uri(uri)
    File.basename(uri.to_s).match(UUID_REGEX)
  end
end
