module CarrierAPI
  class PhoneNumberInventoryStatsRequestSchema < ApplicationRequestSchema
    Group = Struct.new(:name, :column, keyword_init: true)

    COUNTRY_GROUP = Group.new(name: "country", column: :iso_country_code)
    REGION_GROUP = Group.new(name: "region", column: :iso_region_code)
    LOCALITY_GROUP = Group.new(name: "locality", column: :locality)

    GROUPS = [ COUNTRY_GROUP, REGION_GROUP, LOCALITY_GROUP ].freeze

    VALID_GROUP_BY_OPTIONS = [
      [ COUNTRY_GROUP, LOCALITY_GROUP, REGION_GROUP ]
    ]

    def self.error_serializer_class
      JSONAPIRequestSchemaErrorsSerializer
    end

    params do
      required(:filter).value(:hash).hash do
        required(:type).value(:string, eql?: "local")
        required(:available).value(:bool, eql?: true)
        optional(:country).value(:string)
        optional(:region).value(:string)
        optional(:locality).value(:string)
      end
      required(:group_by).value(array[:string])
      optional(:having).value(:hash).hash do
        required(:count).value(:hash).hash do
          optional(:gt).value(:integer, gteq?: 0)
          optional(:gteq).value(:integer, gteq?: 0)
          optional(:lt).value(:integer, gteq?: 0)
          optional(:lteq).value(:integer, gteq?: 0)
          optional(:eq).value(:integer, gteq?: 0)
          optional(:neq).value(:integer, gteq?: 0)
        end
      end
    end

    rule(:group_by) do |context:|
      context[:groups] = find_groups(value)
      key.failure("is invalid") if context[:groups].blank?
    end

    rule(:having) do
      next if value.blank?
      next key.failure("must include a count option") unless value.key?(:count)
      next key.failure("must include one and only one count operator") unless value.fetch(:count).keys.size == 1
    end

    def output
      params = super

      filter = params.fetch(:filter)
      conditions = filter.slice(:type, :locality)
      conditions[:iso_country_code] = filter.fetch(:country) if filter.key?(:country)
      conditions[:iso_region_code] = filter.fetch(:region) if filter.key?(:region)

      {
        named_scopes: :available,
        conditions:,
        groups: context.fetch(:groups),
        having: params.fetch(:having)
      }
    end

    private

    def find_groups(group_names)
      VALID_GROUP_BY_OPTIONS.find { |group_list| group_list.map(&:name) == group_names.sort }
    end
  end
end
