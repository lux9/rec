class TaxIdentificationNumberController < ApplicationController
  # Example request {{localhost_url}}validate_tin?country_iso=AU&number=12345789A3
  def validate_tin
    unless params[:country_iso].presence && params[:number].presence
      return render json: { error: "Not enough data provided, please send country code and number"}

    end
    @country_iso = params[:country_iso].gsub(/\s+/, "").upcase
    @number = params[:number].gsub(/\s+/, "").upcase

    unless countries_supported.include?(@country_iso)
      return render json: { error: "TIN validation not supported for #{params[:country_iso]}" }

    end

    tin = TaxIdentificationNumber.new(country_iso: @country_iso, number: @number)
    tin.process_number if tin.valid?
    json = {}
    json[:valid] = tin.valid?
    json[:tin_type] = tin.tin_type if tin.valid?
    json[:formatted_tin] = tin.to_s if tin.valid?
    json[:business_registration] = tin.business_information if tin.valid? && tin.tin_type == "au_abn"
    json[:errors] = tin.errors.full_messages


    return render json: json

  end

  private

  def countries_supported
    %w[CA AU IN]
  end

end
