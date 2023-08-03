class AddModelsToLines < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :models, :string, length: 255
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
