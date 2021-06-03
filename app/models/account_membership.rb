class AccountMembership < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :user

  enumerize :role, in: %i[owner admin member], predicates: true
end
