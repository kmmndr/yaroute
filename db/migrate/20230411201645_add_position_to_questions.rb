class AddPositionToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :position, :integer, default: 0
  end
end
