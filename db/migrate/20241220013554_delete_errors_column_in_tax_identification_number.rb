class DeleteErrorsColumnInTaxIdentificationNumber < ActiveRecord::Migration[7.1]
  def change
    change_table :tax_identification_numbers do |t|
      t.remove :errors
    end
  end
end
