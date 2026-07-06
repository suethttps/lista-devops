json.extract! tarefa, :id, :titulo, :descricao, :concluida, :created_at, :updated_at
json.url tarefa_url(tarefa, format: :json)
