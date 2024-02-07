class ChecklistItem < ApplicationRecord
  belongs_to :checklist
  validates :ident, uniqueness: { scope: :checklist_id, message: "'ident' tiene que ser unico" }
  validates :ident, presence: { message: "'ident' requerido" }

  enum itemtype: { justtext: 0, tablestart: 1, tableend: 2, tablehead: 3, tablespan: 4, tablemultiwithpic: 5, tableaskwithpic: 6, tableask: 7, tablemulti: 8 }
  enum primaryanswertype: { na: 0, radio2: 1, radio3: 2, radio2big: 3, radio2small: 4 }
  enum secondaryanswertype: { check: 0, torque: 1 }

  def primaryanswertype_options
    [["No aplicable", "justtext"], ["Radio 2", 1], ["Radio 3", 2], ["Radio 2 Grande", 3], ["Radio 2 Pequeño", 4]]
  end

  def secondaryanswertype_options
    [["Checkbox", 0], ["Torque", 1]]
  end

  def itemtype_options
    [["Texto", 0], ["Iniciar Tabla", 1], ["Final Tabla", 2], ["Cabeza de Tabla", 3], ["Span de tabla", 4], ["Multiple con Imagen en Tabla", 5], ["Pregunta con Imagen en Tabla", 6], ["Pregunta en tabla", 7], ["Multiple en tabla", 8]]
  end


  def self.enum_primaryanswertype_to_name(pat)
    case pat
    when na?; "No aplicable"
    when radio2?; "Radio 2"
    when radio3?; "Radio 3"
    when radio2big?; "Radio 2 Grande"
    when radio2small?; "Radio 2 Pequeño"
    else; "NA"
    end
  end

  def self.enum_secondaryanswertype_to_name(sat)
    case sat
    when check?; "Checkbox"
    when torque?; "Torque"
    end
  end

  def self.enum_itemtype_to_name(it)
    case it
    when justtext?; "Texto"
    when tablestart?; "Iniciar Tabla"
    when tableend?; "Final Tabla"
    when tablehead?; "Cabeza de Tabla"
    when tablespan?; "Span de Tabla"
    when tablemultiwithpic?; "Multiple con Imagen en Tabla"
    when tableaskwithpic?; "Pregunta con Imagen en Tabla" 
    when tableask?; "Pregunta en tabla"
    when tablemulti?; "Multple en tabla"
    else; "NA"
    end
  end
end
