class TwilioAPISerializer < ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

  def serializable_hash(options = nil)
    serializable_is_collection? ? hash_for_collection(options) : super
  end
  alias to_hash serializable_hash

  def api_version
    API_VERSION
  end

  def sid
    object.id
  end

  def account_sid
    object.account_id
  end

  private

  def hash_for_collection(options)
    data = object.map do |record|
      self.class.new(record.decorated).serializable_hash(options)
    end

    results = { collection_name => data }
    results.merge(serializer_options.fetch(:pagination_info))
  end

  def serializable_is_collection?
    object.respond_to?(:each) && object.respond_to?(:size)
  end

  def collection_name
    self.class.name.demodulize.gsub("Serializer", "").underscore.pluralize.to_sym
  end

  def format_time(value)
    return if value.blank?

    value.utc.rfc2822
  end
end
