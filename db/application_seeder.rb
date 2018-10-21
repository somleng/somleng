class ApplicationSeeder
  def seed!
    account = Account.first_or_create!
    account.access_token || account.create_access_token!

    print(
      "Account SID:         #{account.sid}\nAuth Token:          #{account.auth_token}"
    )
  end
end
