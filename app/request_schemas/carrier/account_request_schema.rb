class Carrier::AccountRequestSchema < CarrierRequestSchema
  params do
    required(:data).value(:hash).schema do
      required(:type).filled(:str?, eql?: "carrier")
      required(:attributes).value(:hash).schema do
        required(:name).value(:string)
        optional(:metadata).maybe(:hash?)
      end
      required(:relationships).value(:hash).schema do
        optional(:outbound_sip_trunk).value(:hash).schema do
          required(:data).value(:hash).schema do
            required(:type).filled(:str?, eql?: "outbound_sip_trunk")
            required(:id).filled(:str?)
          end
        end
      end
    end
  end

  relationship_rule(:outbound_sip_trunk) do
    break unless key?

    trunk = carrier.outbound_sip_trunks.find_by(id: value)
    key.failure("does not exist") if trunk.blank?
  end

  def output
    result = super
    result[:outbound_sip_trunk] = OutboundSIPTrunk.find(result.fetch(:outbound_sip_trunk)) if result.key?(:outbound_sip_trunk)
    result
  end
end
