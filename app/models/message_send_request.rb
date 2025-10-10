class MessageSendRequest < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :device, class: ApplicationPushDevice
end
