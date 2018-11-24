class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  delegate :serializer_class, to: :class

  def self.serializer_class
    "#{model_name}Serializer".constantize
  end

  def self.between_dates(start_date, end_date, date_column: :created_at)
    start_date ||= Time.at(0).to_date
    end_date ||= Date.current

    where(date_column => (start_date..end_date))
  end
end
