class AuthToken < Doorkeeper::AccessToken
  include FilterableResource
  include OrderableResource
  include DecoratableResource

  belongs_to :account, foreign_key: :resource_owner_id, optional: true

  delegate :active?, to: :access_token

  class << self
    delegate :active, :revoked, to: :access_token_scope

    def decorator_class
      AccessTokenDecorator
    end

    private

    def access_token_scope
      AccessToken::Scope.new(self)
    end
  end

  private

  def access_token
    @access_token ||= AccessToken.new(self)
  end
end
