class ApplicationForm
  extend Enumerize

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
end
