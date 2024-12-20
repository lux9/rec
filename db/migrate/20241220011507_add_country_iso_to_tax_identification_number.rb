class AddCountryIsoToTaxIdentificationNumber < ActiveRecord::Migration[7.1]
  def change
    add_column :tax_identification_numbers, :country_iso, :string
  end
end
