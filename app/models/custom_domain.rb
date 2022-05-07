class CustomDomain < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :carrier

  enumerize :type, in: %i[dashboard api]
  has_secure_token :verification_token

  def self.verified
    where.not(verified_at: nil)
  end

  def verified?
    verified_at.present?
  end

  def verify!
    touch(:verified_at)
  end

  def txt_record
    "somleng-domain-verification=#{verification_token}"
  end
end
