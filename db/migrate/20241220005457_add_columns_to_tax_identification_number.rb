class AddColumnsToTaxIdentificationNumber < ActiveRecord::Migration[7.1]
  # FormattedNumberNumberErrors
  def change
    add_column :tax_identification_numbers, :valid, :boolean, default: false
    add_column :tax_identification_numbers, :formatted_number, :string
    add_column :tax_identification_numbers, :number, :string
    add_column :tax_identification_numbers, :errors, :json
  end
end
