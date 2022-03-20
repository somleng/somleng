class TwilioAPISerializer < ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

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

  def format_time(value)
    return if value.blank?

    value.utc.rfc2822
  end
end
