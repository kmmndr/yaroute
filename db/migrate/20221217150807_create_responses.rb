class CreateResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :responses do |t|
      t.references :question
      t.string :title
      t.boolean :value

      t.timestamps
    end
  end
end
