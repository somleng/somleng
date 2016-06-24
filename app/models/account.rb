class Account < ActiveRecord::Base
  has_one :access_token, :class_name => "Doorkeeper::AccessToken", :foreign_key => :resource_owner_id
  has_many :phone_calls

  alias_attribute :sid, :id

  def auth_token
    access_token && access_token.token
  end
end
