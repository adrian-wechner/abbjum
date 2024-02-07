class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.integer :line_id
      t.string :seq
      t.string :catalog
      t.integer :status
      t.integer :cam_metric1
      t.integer :cam_metric2
      t.integer :cam_metric3
      t.integer :cam_metric4
      t.integer :cam_metric5
      t.integer :cam_metric6
      t.integer :cam_metric7
      t.integer :cam_metric8

      t.timestamps
    end
  end
end
