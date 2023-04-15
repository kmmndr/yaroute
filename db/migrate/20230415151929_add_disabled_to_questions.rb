class AddDisabledToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :disabled, :boolean, default: false
  end
end
