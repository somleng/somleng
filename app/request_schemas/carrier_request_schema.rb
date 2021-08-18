class CarrierRequestSchema < JSONAPIRequestSchema
  option :carrier

  def output
    result = super
    result[:carrier] = carrier
    result
  end
end
