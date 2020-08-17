module TwilioApiResource
  extend ActiveSupport::Concern

  include TwilioTimestamps
  include TwilioJSON

  included do
    alias_attribute :sid, :id
  end
end
