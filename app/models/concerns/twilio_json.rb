module TwilioJSON
  extend ActiveSupport::Concern

  API_VERSION = "2010-04-01"

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only    => json_attributes.keys,
        :methods => json_methods.keys
      }.merge(options)
    )
  end

  def api_version
    API_VERSION
  end

  private

  def json_attributes
    {}
  end

  def json_methods
    {
      :sid => nil,
      :account_sid => nil,
      :uri => nil,
      :date_created => nil,
      :date_updated => nil,
      :api_version => nil
    }
  end
end
