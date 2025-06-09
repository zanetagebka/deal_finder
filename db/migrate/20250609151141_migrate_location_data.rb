class MigrateLocationData < ActiveRecord::Migration[8.0]
  class MigrateLocationData < ActiveRecord::Migration[8.0]
    def up
      Deal.where.not(location_id: nil).find_each do |deal|
        next if deal.merchant.location.present?

        deal.merchant.update(location_id: deal.location_id)
      end
    end

    def down
      raise ActiveRecord::IrreversibleMigration, "Cannot reverse location data migration"
    end
  end
end
