class Export < ApplicationRecord
  extend Enumerize
  enumerize :resource_type, in: %w[Account User]

  belongs_to :user

  before_create :generate_name

  has_one_attached :file

  def ready?
    file.attached?
  end

  private

  def generate_name
    self.name ||= format("%s_%s.csv", resource_type.tableize, Time.current.strftime("%Y%m%d%H%M%S"))
  end
end
