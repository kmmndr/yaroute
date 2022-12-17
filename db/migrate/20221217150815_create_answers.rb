class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.references :player
      t.references :response

      t.timestamps
    end
  end
end
