require 'rails_helper'

RSpec.describe "TaxIdentificationNumbers", type: :request do
  describe "GET /validate_tin" do
    it "returns status :ok" do
      get validate_tin_path(number: "my_number")
      expect(response).to have_http_status(:ok)
    end

    it "returns json" do
      get validate_tin_path(number: "my_number")
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:ok)
    end

    it "returns error when only sending number as param" do
      get validate_tin_path(number: "my_number")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["error"]).to eq("Not enough data provided, please send country code and number")
    end

    it "returns error when only sending country as param" do
      get validate_tin_path(country_iso: "CO")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["error"]).to eq("Not enough data provided, please send country code and number")
    end

    it "returns error when testing AU tin with 10 digits" do
      get validate_tin_path(country_iso: "AU", number: "1234567890")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to eq(["Number Incorrect length (number should contain 9 or 11 digits)"])
    end

    it "returns error when testing AU tin with 9 alphanumeric digits" do
      get validate_tin_path(country_iso: "AU", number: "123A5FD89")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to eq(["Number TIN number must only contain numeric digits"])
    end

    it "returns valid when testing AU tin with 9 numeric digits" do
      get validate_tin_path(country_iso: "AU", number: "123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["valid"]).to be true
    end

    it "returns correct type when testing AU tin with 9 numeric digits" do
      get validate_tin_path(country_iso: "AU", number: "123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["tin_type"]).to eq "au_acn"
    end

    it "returns correct formatted tin when testing AU tin with 9 numeric digits" do
      get validate_tin_path(country_iso: "AU", number: "123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["formatted_tin"]).to eq "123 456 789"
    end

    it "returns correct formatted tin when testing AU tin with 9 numeric digits with trailing spaces and more" do
      get validate_tin_path(country_iso: "AU", number: "  12  3 4 567  8 9       ")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["formatted_tin"]).to eq "123 456 789"
    end

    it "returns correct type when testing AU tin with 11 numeric digits" do
      get validate_tin_path(country_iso: "AU", number: "12123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["tin_type"]).to eq "au_abn"
    end

    it "returns correct formatted tin when testing AU tin with 11 numeric digits" do
      get validate_tin_path(country_iso: "AU", number: "12123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["formatted_tin"]).to eq "12 123 456 789"
    end

    # Canada tests
    it "returns error when testing CA tin with 9 alphanumeric digits" do
      get validate_tin_path(country_iso: "CA", number: "123A5FD89")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to eq(["Number TIN first 9 digits should only contain numeric digits"])
    end

    it "returns error when testing CA tin with 10 numeric digits" do
      get validate_tin_path(country_iso: "CA", number: "1234567890")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to eq(["Number Incorrect length (number should contain 9 or 15 digits)"])
    end

    it "returns error when testing CA tin with 15 alphanumeric digits" do
      get validate_tin_path(country_iso: "CA", number: "123456789NOTRT0")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to eq(["Number TIN last digits should be RT0001"])
    end

    it "returns correct type when testing CA tin with 9 numeric digits" do
      get validate_tin_path(country_iso: "CA", number: "123456789")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["tin_type"]).to eq "ca_gst"
    end

    it "returns correct type when testing CA tin with 15 alphanumeric digits" do
      get validate_tin_path(country_iso: "CA", number: "  123456789RT0001 ")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["tin_type"]).to eq "ca_gst"
    end

    it "returns correct format when testing CA tin with 9 numeric digits" do
      get validate_tin_path(country_iso: "CA", number: "123456789RT0001 ")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["formatted_tin"]).to eq "123456789RT0001"
    end

    # India tests
    it "returns numbers error when testing IN tin with 9 alphanumeric digits" do
      get validate_tin_path(country_iso: "IN", number: "123A5FD89")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to include("Number Incorrect length (number should contain 15 digits)")
    end

    it "returns pattern error when testing IN tin with 9 alphanumeric digits" do
      get validate_tin_path(country_iso: "IN", number: "123A5FD89")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["errors"]).to include("Number TIN number must follow this pattern NNXXXXXXXXXXNAN")
    end

    it "returns correct type when testing IN tin with 15 alphanumeric digits" do
      get validate_tin_path(country_iso: "IN", number: "  22BCDEF1G2FH1Z5 ")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["tin_type"]).to eq "in_gst"
    end

    it "returns correct formmated_tin when testing IN tin with 15 alphanumeric digits" do
      get validate_tin_path(country_iso: "IN", number: "22Basdf1G2FH1Z5")
      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["formatted_tin"]).to eq "22BASDF1G2FH1Z5"
    end

  end
end
