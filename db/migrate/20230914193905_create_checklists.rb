class CreateChecklists < ActiveRecord::Migration[7.0]
  def change
    create_table :checklists do |t|
      t.integer :line_id
      t.string :name

      t.timestamps
    end
  end
end
