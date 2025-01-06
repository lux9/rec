class TaxIdentificationNumberService
  def validate_abn(tax)
    weight_factors = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
    numbers_list = number.chars.map{ |n| n.to_i }
    numbers_list[0] = numbers_list[0] - 1
    multiplied_list = []
    numbers_list.each_with_index {|n, i| multiplied_list << n * weight_factors[i] }
    return multiplied_list.sum % 89 == 0

  end


  def business_information(tin)
    doc = Nokogiri::HTML(URI.open("http://localhost:8080/queryABN?abn=#{tax.number}"))
    name = doc.css("organisationname").inner_text
    address = { state_code: doc.css("statecode").inner_text, postcode: doc.css("postcode").inner_text }
    return { name:, address: }

  rescue OpenURI::HTTPError => e
    return { error: "Could not reach url, error: #{e.message}"}

  end

end