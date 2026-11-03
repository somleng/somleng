class ErrorLogNotification < ApplicationRecord
  belongs_to :error_log
  belongs_to :user

  attribute :message_digest, SHA256Type.new

  def self.create_for!(users:, error_log:)
    insert_all!(
      users.pluck(:email, :id).map do |email, id|
        {
          email:,
          user_id: id,
          error_log_id: error_log.id,
          message_digest: error_log.error_message
        }
      end
    )
  end
end
