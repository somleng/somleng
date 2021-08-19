class TwilioAPISerializer < ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

  def attributes
    {
      "api_version" => nil
    }
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
end
