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

  def clear_params
    @country_iso = SanitizeParams.sanitize_country_iso(params[:country_iso])
    @number = SanitizeParams.sanitize_country_iso(params[:number])
  end


  def check_tin
    if tin.valid?
      json = {}
      json = tin.JSON
      json[:valid] = true
      # json[:tin_type] = tin.tin_type
      # json[:formatted_tin] = tin.to_s
      json[:business_registration] = TaxIdentificationNumberService.business_information(tin) if tin.tin_type == "au_abn"
    else
      json[:errors] = tin.errors.full_messages
    end
  end
end
