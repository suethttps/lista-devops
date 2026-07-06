class CreateTarefas < ActiveRecord::Migration[8.1]
  def change
    create_table :tarefas do |t|
      t.string :titulo, null: false
      t.text :descricao
      t.boolean :concluida, null: false, default: false

      t.timestamps
    end
  end
end
