require "rails_helper"

RSpec.describe InboundSIPTrunk do
  it "revokes the source IP on destroy" do
    stub_app_settings(inbound_sip_trunks_security_group_id: "security-group-id")
    inbound_sip_trunk = create(:inbound_sip_trunk, source_ip: "175.100.7.240")

    expect {
      inbound_sip_trunk.destroy!
    }.to have_enqueued_job(ExecuteWorkflowJob).with(
      "RevokeSecurityGroupIP",
      hash_including(security_group_id: "security-group-id", ip: "175.100.7.240")
    )
  end

  it "authorizes the source IP on create" do
    stub_app_settings(inbound_sip_trunks_security_group_id: "security-group-id")
    carrier = create(:carrier, name: "My Carrier")

    expect {
      create(:inbound_sip_trunk, carrier: carrier, source_ip: "175.100.7.240", name: "My SIP Trunk")
    }.to have_enqueued_job(ExecuteWorkflowJob).with(
      "AuthorizeSecurityGroupIP",
      hash_including(
        ip: "175.100.7.240",
        description: "My Carrier - My SIP Trunk"
      )
    )
  end

  it "revokes the old and authorizes the new source IP on update" do
    stub_app_settings(inbound_sip_trunks_security_group_id: "security-group-id")
    carrier = create(:carrier, name: "My Carrier")
    inbound_sip_trunk = create(
      :inbound_sip_trunk,
      carrier: carrier,
      source_ip: "175.100.7.240",
      name: "My SIP Trunk"
    )

    inbound_sip_trunk.update!(source_ip: "175.100.7.241")
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "RevokeSecurityGroupIP",
      hash_including(ip: "175.100.7.240")
    )
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "AuthorizeSecurityGroupIP",
      hash_including(
        ip: "175.100.7.241",
        description: "My Carrier - My SIP Trunk"
      )
    )
  end
end
