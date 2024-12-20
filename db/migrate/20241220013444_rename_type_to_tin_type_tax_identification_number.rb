class RenameTypeToTinTypeTaxIdentificationNumber < ActiveRecord::Migration[7.1]
  def change
    change_table :tax_identification_numbers do |t|
      t.rename :type, :tin_type
    end
  end
end
