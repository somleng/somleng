class ApplicationSerializer < SimpleDelegator
  include ActiveModel::Serializers::JSON

  attr_reader :serializer_options

  def initialize(object, serializer_options = {})
    super(object)
    @serializer_options = serializer_options
  end

  def attributes
    {}
  end

  def to_json(*args)
    serializable_hash(*args).to_json
  end

  private

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end

  def object
    __getobj__
  end
end
