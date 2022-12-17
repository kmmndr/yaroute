class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :quiz
      t.string :code
      t.timestamp :started_at
      t.integer :current_question_id
      t.timestamp :current_question_at

      t.timestamps
    end

    add_index :games, :code, unique: true
  end
end
