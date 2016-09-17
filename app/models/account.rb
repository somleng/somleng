class Account < ApplicationRecord
  DEFAULT_PERMISSIONS_BITMASK = 0

  has_one :access_token, :class_name => "Doorkeeper::AccessToken", :foreign_key => :resource_owner_id
  has_many :phone_calls
  has_many :incoming_phone_numbers

  bitmask :permissions, :as => [:create_phone_calls], :null => false

  alias_attribute :sid, :id
  before_validation :set_default_permissions_bitmask, :on => :create

  def auth_token
    access_token && access_token.token
  end

  def has_permission_to?(action, resource_class)
    permissions?(permission_name(action, resource_class))
  end

  private

  def set_default_permissions_bitmask
    self.permissions_bitmask = DEFAULT_PERMISSIONS_BITMASK if permissions.empty?
  end

  def permission_name(action, resource_class)
    [action, resource_class.to_s.underscore.pluralize].join("_").to_sym
  end
end
