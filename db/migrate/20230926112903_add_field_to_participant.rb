class AddFieldToParticipant < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :field, :integer, null: false
  end
end
