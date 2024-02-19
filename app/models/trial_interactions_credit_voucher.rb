class TrialInteractionsCreditVoucher < ApplicationRecord
  belongs_to :carrier

  before_create :set_defaults

  private

  def set_defaults
    self.valid_at ||= Time.current
  end
end
