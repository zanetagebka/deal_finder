class CreateMerchants < ActiveRecord::Migration[8.0]
  def change
    create_table :merchants do |t|
      t.string :name
      t.decimal :rating, precision: 3, scale: 2

      t.timestamps
    end
    add_index :merchants, :name, unique: true
  end
end
