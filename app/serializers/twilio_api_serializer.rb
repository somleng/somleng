class TwilioAPISerializer < ApplicationSerializer
  def serializable_hash(options = nil)
    serializable_is_collection? ? hash_for_collection(options) : super
  end
  alias to_hash serializable_hash

  private

  def hash_for_collection(options)
    data = object.map do |record|
      self.class.new(record.decorated, serializer_options).serializable_hash(options)
    end

    results = { collection_name => data }
    pagination_results = pagination_serializer.serializable_hash
    results.merge(pagination_results)
  end

  def pagination_serializer
    TwilioAPI::PaginationSerializer.new(serializer_options.fetch(:pagination_info))
  end

  def serializable_is_collection?
    object.respond_to?(:each) && object.respond_to?(:size)
  end

  def collection_name
    self.class.name.demodulize.gsub("Serializer", "").underscore.pluralize.to_sym
  end
end
