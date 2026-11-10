class MessagingServiceAlphanumericSenderID < ApplicationRecord
  belongs_to :sender_id, class_name: "AlphaNumericSenderID"
  belongs_to :messaging_service
end
