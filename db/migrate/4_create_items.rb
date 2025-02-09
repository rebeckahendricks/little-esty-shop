class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :unit_price, null: false
      t.belongs_to :merchant, foreign_key: true

      t.timestamps
    end
  end
end
