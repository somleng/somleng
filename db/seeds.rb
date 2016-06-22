account = Account.first_or_create!
access_token = account.access_token || account.create_access_token!

puts "Account SID: #{account.sid}"
puts "Auth Token:  #{account.auth_token}"
