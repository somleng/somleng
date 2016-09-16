module TwilioJson
  extend ActiveSupport::Concern

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :methods => [:sid, :account_sid, :uri, :date_created, :date_updated]
      }.merge(options)
    )
  end
end
