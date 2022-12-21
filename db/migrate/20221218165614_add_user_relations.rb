class AddUserRelations < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :user_id, :integer
    add_column :games, :user_id, :integer
    add_column :quizzes, :user_id, :integer
  end
end
