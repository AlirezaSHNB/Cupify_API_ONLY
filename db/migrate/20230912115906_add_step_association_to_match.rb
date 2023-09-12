class AddStepAssociationToMatch < ActiveRecord::Migration[7.0]
  def change
    add_reference :matches, :step, null: false, index: true, foreign_key: true
  end
end
