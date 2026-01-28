module CarrierAPI
  class PriceParameterParser
    def parse(price, currency)
      amount = InfinitePrecisionMoney.from_amount(price, currency).abs
      [ amount.cents, currency ]
    end
  end
end
