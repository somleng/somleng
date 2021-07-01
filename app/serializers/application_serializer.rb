class ApplicationSerializer < SimpleDelegator
  include ActiveModel::Serializers::JSON

  API_VERSION = "2010-04-01".freeze

  attr_reader :options

  def initialize(resource, options = {})
    super(resource)
    @options = options
  end

  def attributes
    {
      "api_version" => nil
    }
  end

  def to_json(*args)
    serializable_hash(*args).to_json
  end

  def api_version
    API_VERSION
  end

  def sid
    __getobj__.id
  end

  def account_sid
    __getobj__.account_id
  end

  private

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end
