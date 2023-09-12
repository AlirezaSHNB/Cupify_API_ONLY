class AddIsRoundTripFinalToKnockout < ActiveRecord::Migration[7.0]
  def change
    add_column :knockouts, :is_round_trip_final, :boolean, default: false
  end
end
