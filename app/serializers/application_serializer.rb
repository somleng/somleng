class ApplicationSerializer < SimpleDelegator
  include ActiveModel::Serializers::JSON

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
