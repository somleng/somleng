module TwilioTimestamps
  extend ActiveSupport::Concern

  def date_created
    created_at.rfc2822
  end

  def date_updated
    updated_at.rfc2822
  end
end
