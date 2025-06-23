class FeatureFlag
  PERMISSIONS = {
    "d28bb460-1324-4aa5-860a-8ef48fb5ca7f" => [ :broadcasts ],
    "32217a9c-c578-45ce-acd9-550e5b4a8f0f" => [ :broadcasts ],
    "d1bc9915-ed19-4152-bf7c-b651979e4491" => [ :broadcasts ],
    "973e2da2-df4e-43b4-ab50-8d4ca091c116" => [ :broadcasts ]
  }

  class << self
    def enabled_for?(user, flag)
      PERMISSIONS.fetch(user.id, []).include?(flag)
    end
  end
end
