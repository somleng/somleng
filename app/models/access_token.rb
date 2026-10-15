class AccessToken
  class Scope
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def active
      scope.where(revoked_at: nil).or(scope.where(revoked_at: Time.current..))
    end

    def revoked
      scope.where(revoked_at: ..Time.current)
    end
  end

  attr_reader :access_token

  def initialize(access_token)
    @access_token = access_token
  end

  def active?
    access_token.revoked_at.blank? || access_token.revoked_at.future?
  end
end
