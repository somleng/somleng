class AuthToken < Doorkeeper::AccessToken
  include FilterableResource
  include OrderableResource
  include DecoratableResource

  belongs_to :account, foreign_key: :resource_owner_id, optional: true
  has_one :primary_account, class_name: "Account", foreign_key: :primary_auth_token_id

  delegate :active?, to: :access_token

  class << self
    delegate :active, :revoked, to: :access_token_scope

    def primary
      joins(:primary_account)
    end

    def secondary
      joins(:account).where.missing(:primary_account)
    end

    private

    def access_token_scope
      AccessToken::Scope.new(self)
    end
  end

  def primary?
    account.primary_auth_token == self
  end

  def promote!
    account.update!(primary_auth_token: self)
  end

  private

  def access_token
    @access_token ||= AccessToken.new(self)
  end
end
