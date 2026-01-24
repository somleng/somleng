class OnboardCarrier < ApplicationWorkflow
  attr_reader :name, :country_code, :owner_params, :restricted, :website, :subdomain, :billing_currency

  def initialize(**params)
    super()
    @name = params.fetch(:name)
    @country_code = params.fetch(:country_code)
    @restricted = params.fetch(:restricted)
    @subdomain = params.fetch(:subdomain)
    @website = params.fetch(:website)
    @owner_params = params.fetch(:owner)
    @billing_currency = params.fetch(:billing_currency) { ISO3166::Country.new(country_code).currency_code }
  end

  def call
    ApplicationRecord.transaction do
      carrier = create_carrier
      create_carrier_access_token(carrier)
      owner = onboard_carrier_owner(carrier:, **owner_params)
      [ carrier, owner ]
    end
  end

  private

  def create_carrier
    Carrier.create!(
      name:,
      country_code:,
      website:,
      subdomain:,
      restricted:,
      billing_currency:,
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

  def onboard_carrier_owner(**params)
    user_params = params.reverse_merge(
      carrier_role: :owner
    )

    user_params.key?(:password) ? User.create!(user_params) : User.invite!(user_params)
  end
end
