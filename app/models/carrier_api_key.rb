class CarrierAPIKey < Doorkeeper::AccessToken
  include FilterableResource
  include OrderableResource
  include DecoratableResource

  belongs_to :oauth_application, foreign_key: :application_id
  delegate :active?, to: :access_token

  class << self
    delegate :active, :revoked, to: :access_token_scope

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
