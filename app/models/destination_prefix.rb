class DestinationPrefix < ApplicationRecord
  belongs_to :destination_group

  def self.longest_match_for(number)
    where("? LIKE prefix || '%'", number).order(Arel.sql("LENGTH(prefix) DESC")).first
  end
end
