class TaxIdentificationNumberController < ApplicationController
  # Example request {{localhost_url}}validate_tin?country_iso=AU&number=12345789A3
  def validate_tin
    unless params[:country_iso].presence && params[:number].presence
      return render json: { error: "Not enough data provided, please send country code and number"}
    end

    sanitize_params
    tin = TaxIdentificationNumber.new(country_iso: @country_iso, number: @number)

    return render json: json
  end

  private

end
