module CarrierAPI
  class AggregateDataSerializer < JSONAPISerializer
    attribute :statistic do |object|
      statistic = {}
      object.groups.each_with_index do |group, index|
        statistic[group.name] = object.key[index]
      end

      statistic[:value] = object.value
      statistic
    end
  end
end
