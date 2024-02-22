class ErrorLogNotification < ApplicationRecord
  belongs_to :error_log
  belongs_to :user

  attribute :message_digest, SHA256Type.new
end
