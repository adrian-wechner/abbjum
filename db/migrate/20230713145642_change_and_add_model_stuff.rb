class ChangeAndAddModelStuff < ActiveRecord::Migration[7.0]
  def change
    rename_column :lines, :models, :station_models
    add_column :lines, :model_translation, :text
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")  
  end
end
