class AddMerchantToDeal < ActiveRecord::Migration[8.0]
  def change
    add_reference :deals, :merchant, null: false, foreign_key: true
  end
end
