class CreateMatchParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :match_participants do |t|
      t.references :match, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
