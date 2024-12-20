class ReomoveValidColumnInTaxIdentificationNumber < ActiveRecord::Migration[7.1]
  def change
    change_table :tax_identification_numbers do |t|
      t.remove :valid
    end
  end
end
