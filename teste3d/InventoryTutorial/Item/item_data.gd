# Classe base para dados de itens, herdando de Resource, que permite criar recursos personalizados no Godot
extends Resource

# Define o nome da classe como ItemData para ser reconhecida e utilizada em outros scripts
class_name ItemData

# Variáveis exportadas que definem as propriedades básicas de um item
@export var name: String = ""  # Nome do item
@export_multiline var description: String = ""  # Descrição do item, permite múltiplas linhas no editor
@export var stackable: bool = false  # Define se o item pode ser empilhado (stackable) no inventário
@export var texture: AtlasTexture  # Textura associada ao item, utilizada para representá-lo visualmente

# Função de uso do item, destinada a ser sobrescrita por subclasses
func use(target) -> void:
	pass  # Função vazia, a ser implementada por classes que herdam de ItemData