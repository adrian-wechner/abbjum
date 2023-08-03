class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string :name
      t.integer :line_id
      t.string :model
      t.string :operator_instructions
      t.string :ingersoll_ips
      t.string :hipot_ips

      t.timestamps
    end
  end
end
