class Tarefa < ApplicationRecord
  validates :titulo, presence: true

  scope :pendentes, -> { where(concluida: false) }
  scope :concluidas, -> { where(concluida: true) }
end
