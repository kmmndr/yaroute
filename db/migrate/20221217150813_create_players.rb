class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.references :game
      t.string :name

      t.timestamps
    end
  end
end
