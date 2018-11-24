class ApiResourceSerializer < ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

  def account_sid
    serializable.account_id
  end

  def api_version
    API_VERSION
  end

  def sid
    serializable.id
  end

  def date_created
    serializable.created_at.rfc2822
  end

  def date_updated
    serializable.updated_at.rfc2822
  end
end
