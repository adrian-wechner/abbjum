class CreateChecklistRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_records do |t|
      t.integer :checklist_id
      t.integer :user_start_id
      t.integer :user_complete_id
      t.integer :line_id
      t.string :catalogue
      t.datetime :checkstart
      t.datetime :checkend
      t.integer :quantity
      t.integer :shift
      t.text :comments
      t.boolean :deviationrun
      t.text :deviationcomment

      t.timestamps
    end
  end
end
