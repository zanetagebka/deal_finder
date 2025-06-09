class AddLocationToMerchant < ActiveRecord::Migration[8.0]
  def change
    add_reference :merchants, :location, foreign_key: true, null: true
  end
end
