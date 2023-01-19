class FixAccountsLoginIndexUniqueness < ActiveRecord::Migration[7.0]
  def change
    remove_index :accounts, :login, unique: false
    add_index :accounts, :login, unique: true
  end
end
