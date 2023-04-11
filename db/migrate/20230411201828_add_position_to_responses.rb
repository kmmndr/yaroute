class AddPositionToResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :responses, :position, :integer, default: 0
  end
end
