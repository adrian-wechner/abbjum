class AddPartInstanceToStation < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :part_instance, :string
  end
end
