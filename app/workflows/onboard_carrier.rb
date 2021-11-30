class OnboardCarrier < ApplicationWorkflow
  attr_reader :name, :country_code, :owner

  def initialize(params)
    @name = params.fetch(:name)
    @country_code = params.fetch(:country_code)
    @owner = params.fetch(:owner)
  end

  def call
    ApplicationRecord.transaction do
      carrier = create_carrier
      create_carrier_access_token(carrier)
      invite_carrier_owner(carrier: carrier, **owner)
      carrier
    end
  end

  private

  def create_carrier
    Carrier.create!(
      name: name,
      country_code: country_code
    )
  end

  def create_carrier_access_token(carrier)
    OAuthApplication.create!(
      name: carrier.name,
      owner: carrier,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      scopes: "carrier_api"
    ) do |app|
      Doorkeeper::AccessToken.create!(
        application: app,
        scopes: app.scopes
      )
    end
  end

  def invite_carrier_owner(params)
    User.invite!(
      params.reverse_merge(
        carrier_role: :owner
      )
    )
  end
end
