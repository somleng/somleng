class ApplicationSerializer < SimpleDelegator
  attr_reader :serializable, :options

  class << self
    def attributes(*names)
      _attribute_list.concat(names)
    end

    def _attribute_list
      @_attribute_list ||= []
    end
  end

  def initialize(serializable, options = {})
    @serializable = serializable
    @options = options
    super(serializable)
  end

  def serializable_hash(_options = nil)
    serializable_is_collection? ? hash_for_collection : hash_for_one_record
  end
  alias to_hash serializable_hash

  def as_json(_options = nil)
    serializable_hash.as_json
  end

  def to_json(_option = nil)
    serializable_hash.to_json
  end

  private

  def hash_for_one_record
    populate_attributes(self.class._attribute_list)
  end

  def populate_attributes(attribute_list, accumulator = {})
    attribute_list.each_with_object(accumulator) do |attribute, data|
      data[attribute] = public_send(attribute)
    end
  end

  def hash_for_collection
    serializable.map do |record|
      self.class.new(record, options).serializable_hash
    end
  end

  def serialize_collection(data, item_serializer_class:)
    item_serializer_class.new(data, **options)
  end

  def serializable_is_collection?
    serializable.respond_to?(:each) && serializable.respond_to?(:size)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
