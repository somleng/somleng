class FeatureFlag
  PERMISSIONS = {
    "d28bb460-1324-4aa5-860a-8ef48fb5ca7f" => [ :broadcasts ],
    "32217a9c-c578-45ce-acd9-550e5b4a8f0f" => [ :broadcasts ],
    "d1bc9915-ed19-4152-bf7c-b651979e4491" => [ :broadcasts ],
    "973e2da2-df4e-43b4-ab50-8d4ca091c116" => [ :broadcasts ],
    "5c9889cf-5f84-4547-b2bf-fbdcf22a38f3" => [ :broadcasts ],
    "7a631ca8-b66a-42e9-a1e0-c432f0621b62" => [ :broadcasts ],
    "4f761c2d-fc7b-44e0-a907-f2c15e6ac7fa" => [ :broadcasts ],
    "65da5e4f-a990-482c-b4c9-fa0849a6233f" => [ :broadcasts ],
    "986bbbc7-e38f-4780-8c99-77181085a49b" => [ :broadcasts ],
    "cb2dc3b6-c347-41d9-aaac-498b4f5bc28f" => [ :broadcasts ],
    "fff20142-6114-4017-b346-b6c4d0fb269f" => [ :broadcasts ]
  }

  class << self
    def enabled_for?(user, flag)
      PERMISSIONS.fetch(user.id, []).include?(flag)
    end
  end
end
