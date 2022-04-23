class CreateInteraction < ApplicationWorkflow
  GUESSED_BENEFICIARY_COUNTRIES = [
    "US", "AU", "NF", "FI", "NO", "MA", "FK", "GB", "IT", "RU", "NZ", "RE"
  ].freeze

  attr_reader :params, :interactable, :beneficiary_country

  def initialize(params)
    @params = params
    @interactable = params.fetch(:interactable)
    @beneficiary_country = find_beneficiary_country
  end

  def call
    Interaction.create!(
      interactable:,
      carrier: interactable.carrier,
      account: interactable.account,
      beneficiary_country_code: beneficiary_country&.alpha2,
      **params
    )
  end

  private

  def find_beneficiary_country
    return possible_beneficiary_countries.first if possible_beneficiary_countries.size == 1

    possible_beneficiary_countries.find(-> { guess_beneficiary_country }) do |c|
      c == interactable.carrier.country
    end
  end

  def possible_beneficiary_countries
    @possible_beneficiary_countries ||= begin
      country_code = Phony.split(params.fetch(:beneficiary_identifier)).first
      ISO3166::Country.find_all_country_by_country_code(country_code)
    end
  end

  def guess_beneficiary_country
    possible_beneficiary_countries.find { |c| GUESSED_BENEFICIARY_COUNTRIES.include?(c.alpha2) }
  end
end
