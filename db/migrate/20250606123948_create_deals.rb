class CreateDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :deals do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :original_price, precision: 10, scale: 2, null: false
      t.decimal :discount_price, precision: 10, scale: 2, null: false
      t.integer :discount_percentage, null: false
      t.string :category, null: false
      t.string :subcategory
      t.json :tags, default: []

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code

      t.string :merchant_name, null: false
      t.decimal :merchant_rating, precision: 3, scale: 2

      t.integer :quantity_sold, default: 0
      t.integer :review_count, default: 0
      t.decimal :average_rating, precision: 3, scale: 2
      t.integer :available_quantity

      t.date :expiry_date, null: false
      t.boolean :featured_deal, default: false
      t.string :image_url
      t.text :fine_print
      t.json :meta, default: {}

      t.timestamps
    end

    add_index :deals, [ :category, :discount_price ]
    add_index :deals, [ :expiry_date, :available_quantity ]
    add_index :deals, [ :latitude, :longitude ]
    add_index :deals, :quantity_sold
    add_index :deals, :featured_deal
    add_index :deals, [ :city, :state ]
  end
end
