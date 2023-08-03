class Station < ApplicationRecord
  belongs_to :line
  validates :name, length: { minimum: 1 }

  def has_dft?
    operator_instructions.upcase.split(",").include?("DFT")
  end

  def has_qg?
    operator_instructions.upcase.split(",").include?("QG")
  end
end
