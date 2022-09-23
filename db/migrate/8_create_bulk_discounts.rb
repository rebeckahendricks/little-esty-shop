class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.belongs_to :merchant, foreign_key: true
      t.integer :discount, null: false
      t.integer :threshold, null: false

      t.timestamps
    end
  end
end
