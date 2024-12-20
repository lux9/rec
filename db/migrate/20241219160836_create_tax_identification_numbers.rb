class CreateTaxIdentificationNumbers < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_identification_numbers do |t|
      t.integer :type, default: 0, null: false
      t.timestamps
    end
  end
end
