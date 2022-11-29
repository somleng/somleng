class MessagingServiceSender < ApplicationRecord
  belongs_to :phone_number
  belongs_to :messaging_service
end
