class RemoveLeagueWeakFromMatches < ActiveRecord::Migration[7.0]
  def change
    remove_column :matches, :league_weak, :integer
  end
end
