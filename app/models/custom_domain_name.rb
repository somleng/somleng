class CustomDomainName < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :carrier

  enumerize :type, in: %i[dashboard api]
end
