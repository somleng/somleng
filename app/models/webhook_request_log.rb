class WebhookRequestLog < ApplicationRecord
  belongs_to :event
  belongs_to :webhook_endpoint

  def self.failed
    where(failed: true)
  end
end
