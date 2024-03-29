class MediaStreamEvent < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :media_stream
  belongs_to :phone_call
end
