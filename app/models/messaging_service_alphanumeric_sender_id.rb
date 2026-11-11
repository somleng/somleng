class MessagingServiceAlphanumericSenderID < ApplicationRecord
  belongs_to :sender_id, class_name: "AlphanumericSenderID"
  belongs_to :messaging_service
end
