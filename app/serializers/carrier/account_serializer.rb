class Carrier::AccountSerializer < JSONAPIResourceSerializer
  attributes :name, :status, :metadata
end
