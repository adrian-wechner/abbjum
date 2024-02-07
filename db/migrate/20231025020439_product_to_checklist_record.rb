class ProductToChecklistRecord < ActiveRecord::Migration[7.0]
  def change
    add_column :checklist_records, :product_id, :integer
    remove_column :checklist_records, :catalogue
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
