class CustomDomain < ApplicationRecord
  extend Enumerize

  belongs_to :carrier

  enumerize :host_type, in: %i[dashboard api mail]
  enumerize :dns_record_type, in: %i[txt cname]
  has_secure_token :verification_token

  def self.verified
    where.not(verified_at: nil)
  end

  def verifiable?
    !verified?
  end

  def verified?
    verified_at.present?
  end

  def mark_as_verified!
    touch(:verified_at)
  end

  def record_name
    host
  end

  def record_value
    "somleng-domain-verification=#{verification_token}"
  end
end
