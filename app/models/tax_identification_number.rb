class TaxIdentificationNumber < ApplicationRecord
  enum :tin_type, %i[au_abn au_acn ca_gst in_gst]
  validates :number, :country_iso, presence: true
  validate :check_valid

  def check_valid
    case country_iso
    when "AU"
      check_errors_au
    when "CA"
      check_errors_ca
    when "IN"
      check_errors_in
    else
      errors.add(:country_iso, "Invalid Country ISO, please check and try again")
    end
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
    self.formatted_number = format_number
    return true

  end

  def format_number
    case tin_type
    when "au_acn"
      return number.scan(/.../).join(" ")

    when "au_abn"
      return [number[0..1], number[2..].scan(/.../)].join(" ")

    when "ca_gst"
      return number if number.length == 15
      return "#{number}RT0001"

    when "in_gst"
      return number

    end
  end

  def check_errors_au
    return unless number

    if number.length != 9 && number.length != 11
      errors.add(:number, "Incorrect length (number should contain 9 or 11 digits)")
    end

    if number.match(/[A-Z]/i)
      errors.add(:number, "TIN number must only contain numeric digits")
    end

    if number.length == 11 && !validate_abn
      errors.add(:number, "TIN number does not pass ABR validations")
    end
  end

  def check_errors_ca
    if number.length != 9 && number.length != 15
      errors.add(:number, "Incorrect length (number should contain 9 or 15 digits)")
    end

    if number[0..8].match(/[A-Z]/i)
      errors.add(:number, "TIN first 9 digits should only contain numeric digits")
    end

    if number.length == 15 && number[9..] != "RT0001"
      errors.add(:number, "TIN last digits should be RT0001")
    end
  end

  def check_errors_in
    if number.length != 15
      errors.add(:number, "Incorrect length (number should contain 15 digits)")
    end

    unless number.match(/^\d{2}.{10}\d\D\d$/i)
      errors.add(:number, "TIN number must follow this pattern NNXXXXXXXXXXNAN")
    end
  end

  def validate_abn
    weight_factors = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
    numbers_list = number.chars.map{ |n| n.to_i }
    numbers_list[0] = numbers_list[0] - 1
    multiplied_list = []
    numbers_list.each_with_index {|n, i| multiplied_list << n * weight_factors[i] }
    return multiplied_list.sum % 89 == 0

  end

  def to_s
    formatted_number
  end

end
