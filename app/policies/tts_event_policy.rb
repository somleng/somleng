class TTSEventPolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end
end
