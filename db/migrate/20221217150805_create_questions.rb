class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.references :quiz
      t.string :title
      t.integer :points, default: 1, null: false
      t.integer :duration, default: 15

      t.timestamps
    end
  end
end
