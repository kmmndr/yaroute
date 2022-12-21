class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.references :user
      t.string :login
      t.string :password_hash

      t.timestamps
    end

    add_index :accounts, :login, unique: false
  end
end
