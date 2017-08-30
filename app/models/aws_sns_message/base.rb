class AwsSnsMessage::Base < ApplicationRecord
  self.table_name = :aws_sns_messages

  validates :type,
            :presence => true

  validates :aws_sns_message_id,
            :presence => true,
            :uniqueness => true
end
