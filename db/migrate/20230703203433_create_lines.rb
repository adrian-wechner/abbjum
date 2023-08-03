class CreateLines < ActiveRecord::Migration[7.0]
  def change
    create_table :lines do |t|
      t.string :name
      t.string :localpath
      t.string :remotepath
      t.string :trackingpath

      t.timestamps
    end
  end
end
