class AddUniqueResponseIndexToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_index :answers, [:player_id, :response_id], unique: true
  end
end
