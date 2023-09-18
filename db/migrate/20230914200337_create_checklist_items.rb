class CreateChecklistItems < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_items do |t|
      t.integer :checklist_id
      t.string :ident
      t.string :label
      t.string :primaryanswers
      t.integer :primaryanswertype
      t.integer :itemtype
      t.integer :ordernum
      t.integer :secondaryanswertype

      t.timestamps
    end
  end
end
