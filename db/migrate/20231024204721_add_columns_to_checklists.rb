class AddColumnsToChecklists < ActiveRecord::Migration[7.0]
  def change
    add_column :checklists, :title, :string
    add_column :checklist_records, :serialfirst, :string
    add_column :checklist_records, :serialmid, :string
    add_column :checklist_records, :seriallast, :string
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
