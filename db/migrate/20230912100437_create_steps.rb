class CreateSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :steps do |t|
      t.string :name
      t.integer :phase
      t.references :league, foreign_key: true
      t.references :knockout, foreign_key: true
      t.references :cup, null: false, foreign_key: true
      t.integer :state

      t.timestamps
    end
  end
end
