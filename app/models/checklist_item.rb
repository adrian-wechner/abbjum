class ChecklistItem < ApplicationRecord
  belongs_to :checklist

  enum itemtype: { justtext: 0, tablestart: 1, tableend: 2, tablehead: 3, tablespan: 4, tablemultiwithpic: 5, tableaskwithpic: 6, tableask: 7, tablemulti: 8 }

  def enum_to_name
    case itemtype
    when justtext?; "Texto"
    when tablestart?; "Iniciar Tabla"
    when tableend?; "Final Tabla"
    when tablehead?; "Cabeza de Tabla"
    else; "NA"
    end
  end
end
