class AddLocationToDeal < ActiveRecord::Migration[8.0]
  def change
    add_reference :deals, :location, foreign_key: true
  end
end
