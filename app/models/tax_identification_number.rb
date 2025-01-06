require 'nokogiri'
require 'open-uri'
class TaxIdentificationNumber < ApplicationRecord
  enum :tin_type, %i[au_abn au_acn ca_gst in_gst]
  validates :number, :country_iso, presence: true
  validate :check_country_errors, :check_api_errors, :check_number_errors
  
  def countries_supported
    %w[CA AU IN]
  end

  def check_support
    unless countries_supported.include?(@country_iso)
      errors.add(:country_iso, "TIN number does not match then length")
    end
  end

  rules = {
    au: {default: {tin_type: 1}, {check_sum_errors: true}, {valid_length: [9, 11]}},
    ca: {default: {tin_type: 2}, {check_sum_errors: false}, {valid_length: [5]}},
    au: {default: {tin_type: 3}, {check_sum_errors: false}},
  }
  
  # :check_country_errors, :check_api_errors, :check_number_errors a.valid?
  
  before_validation :validate_country_errors, :validate_api_errors, :validate_number_errors
  .valid?

  def check_valid
    check_country_errors
    check_api_errors
    check_number_errors
    external_validations
  end

  def process_number
    case country_iso
    when "AU"
      self.tin_type = 1 if number.length == 9
      self.tin_type = 0 if number.length == 11
    when "CA"
      self.tin_type = 2
    when "IN"
      self.tin_type = 3
    end
    format_number(self)
    return true

  end

  def format_number(tax)
    case tax.tin_type
    when "au_acn"
      e = number.scan(/.../).join(" ")
    when "au_abn"
      e = [number[0..1], number[2..].scan(/.../)].join(" ")
    when "ca_gst"
      e = number if number.length == 15
      e = "#{number}RT0001"
    when "in_gst"
      e = number
    end
    self.number = e
  end

  def check_country_length_errors
    return unless number

    unless rules[self.country_iso][:valid_length].include? number.length
      errors.add(:number, "TIN number does not match then length")
    end

    if rules[self.coutry_iso.downcase]["check_sum_error"]
      errors.add(:number, "TIN number does not pass ABR validations") if !TaxIdentificationNumberSanitizer.validate_abn
      external_validations
    end

    unless number.match(/^\d{2}.{10}\d\D\d$/i)
      errors.add(:number, "TIN number must follow this pattern NNXXXXXXXXXXNAN")
    end
  end
  
  def external_validations
    doc = Nokogiri::HTML(URI.open("http://localhost:8080/queryABN?abn=#{number}"))
    valid = doc.css("goodsandservicestax").inner_text == "true"
    errors.add(:number, "business is not GST registered") unless valid

  rescue OpenURI::HTTPError => e
    errors.add(:number, "Error accessing the API, #{e.message}")
    return

  end
  

  def validate_format
    if number.match(/[A-Z]/i)
      errors.add(:number, "TIN number must only contain numeric digits")
    end

    if number[0..8].match(/[A-Z]/i)
      errors.add(:number, "TIN first 9 digits should only contain numeric digits")
    end
  end


end
