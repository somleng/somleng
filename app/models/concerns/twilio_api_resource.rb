module TwilioApiResource
  extend ActiveSupport::Concern

  include TwilioTimestamps
  include TwilioJson

  included do
    alias_attribute :sid, :id
  end
end
