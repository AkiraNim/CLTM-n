extends CharacterBody3D

# Sinais para comunicação
signal dialog

# Variáveis exportadas
@export var emotion: int
@export var npc_name: String
@export var inventory_data: InventoryData
@export var has_dialog: bool = false
@export var quantity_needed: int

@onready var pop_up: Control = $"../../Ui/PopUp"
# Variáveis de controle

var rng = RandomNumberGenerator.new()
var mission: Mission
var mission_found = false
var mission_completed: bool = false
var npc_id: int
# Constantes para movimento e emoções

const WALK_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const EMOTION_CRYING = 0
const EMOTION_SIT = 1
const EMOTION_IDLE_SAD = 2
const EMOTION_IDLE = 3
const EMOTION_WALKING = 4
const EMOTION_RUNNING = 5

# Referências a nós prontos
@onready var animation_player: AnimationPlayer = $Women5/AnimationPlayer
@export var path_follow_3d: PathFollow3D
@export var have_path: bool
@export var RUN_SPEED = 2.0
# Inicialização do NPC
func _ready() -> void:
	rng.randomize()
	var npc: Npc = Npc.new()
	
	npc.emotion = emotion
	npc.inventory_data = inventory_data
	npc.npc_name = npc_name
	npc_id = rng.randi_range(0,1000000)
	npc.npc_id = npc_id
	for npcs in NpcManager.npcs:
		if npcs.npc_id == npc_id:
			while npcs.npc_id == npc_id:
				npc_id = rng.randi_range(0,10000)
				npc.npc_id = npc_id
	
	NpcManager.add_npc(npc)
	
	update_emotion_animation()
	
	"Exemplo de uso da funcao de criar missoes"
	#for npcs in NpcManager.npcs:
		#if npcs.npc_id == npc_id:
			#if MissionManager.create_new_mission(npc_id, "Encontrar 2 maçãs", "Ajude o npc a encontrar maçãs", "50 moedas"):
				#pop_up.set_popup_text("Nova missao adicionada", 2.0)
				
func _physics_process(delta: float) -> void:
	play_animation_based_on_emotion(delta)
	for missions in PlayerManager.player.missions_complete:
		if missions.npc_id == npc_id:
			play_animation_based_on_emotion(3)
# Atualiza a animação baseada na emoção
func update_emotion_animation() -> void:
	play_animation_based_on_emotion(0)

# Controla a animação com base na emoção
func play_animation_based_on_emotion(delta: float) -> void:
	match emotion:
		EMOTION_CRYING:
			animation_player.play("CryingIdle")
		EMOTION_SIT:
			animation_player.play("SitIdle")
		EMOTION_IDLE_SAD:
			animation_player.play("IdleSad")
		EMOTION_IDLE:
			animation_player.play("Idle")
		EMOTION_WALKING:
			if have_path:
				animation_player.play("Walk")
				path_follow_3d.progress += WALK_SPEED * delta
		EMOTION_RUNNING:
			if have_path:
				animation_player.play("Run")
				path_follow_3d.progress += RUN_SPEED * delta

# Função chamada quando o jogador interage com o NPC

func player_interact() -> void:
	var id
	for missions in MissionManager.get_available_missions():
		if missions.title == "Recados dados"\
		and has_dialog:
			if Dialogic.current_timeline == null:
				Dialogic.start('mulher')
				has_dialog = false  # Diálogo específico
				get_viewport().set_input_as_handled()
				if !has_dialog:
					drop_npc_slot_data_by_name("Livro marrom")
					PlayerManager.player.add_money(+30)
					pop_up.set_popup_text("Item recebido Livro marrom\n+R$30.00", 2.0)
					for mission in MissionManager.get_available_missions():
						if mission.title == "Recados dados":
							mission.complete_mission(mission)
	drop_npc_slot_data_by_name("Livro marrom")
# Função que checa os itens do NPC
func check_npc_items() -> Array:
	var items := []
	for npcs in NpcManager.npcs:
		if npcs.npc_id == npc_id:
			for i in range(npcs.inventory_data.slot_datas.size()):
				var slot_data = npcs.inventory_data.slot_datas[i]
				if slot_data:
					var item_name = npcs.inventory_data.get_slot_data_name(i)
					items.append(item_name)
	return items

func drop_item_from_npc(npc_id: int, index: int) -> void:
	var grabbed_slot_data: SlotData = null
	# Procura o NPC específico pelo npc_id
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			
			# Pega os dados do slot especificado e remove o item do inventário
			if index < npc.inventory_data.slot_datas.size():
				grabbed_slot_data = npc.inventory_data.slot_datas[index]
				if grabbed_slot_data and !PlayerManager.player.player_have_this_item(grabbed_slot_data.item_data):
					npc.inventory_data.slot_datas[index] = null
					npc.inventory_data.inventory_updated.emit(npc.inventory_data)
	
	if grabbed_slot_data:
		
		PlayerManager.player.inventory_data.pick_up_slot_data(grabbed_slot_data)
func drop_all_npc_slot_data() -> void:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range(npc.inventory_data.slot_datas.size()):
				if npc.inventory_data.slot_datas[i]:
					drop_item_from_npc(npc.npc_id, i)

# Solta um item específico do NPC
func drop_npc_slot_data_by_name(name: String) -> void:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range(npc.inventory_data.slot_datas.size()):
				if npc.inventory_data.get_slot_data_name(i) == name:
					drop_item_from_npc(npc.npc_id, i)

func remove_npc_slot_data_by_index(npc_id: int, index: int)-> void:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range (npc.inventory_data.slot_datas.size()):
				if i == index:
					npc.inventory_data.slot_datas[index] = null
					npc.inventory_data.inventory_updated.emit(npc.inventory_data)

func remove_npc_slot_data_by_name(name: String)-> void:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range (npc.inventory_data.slot_datas.size()):
				if npc.inventory_data.get_slot_data_name(i) == name:
					remove_npc_slot_data_by_index(npc.npc_id, i)

func remove_all_npc_slot_data()-> void:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range(npc.inventory_data.slot_datas.size()):
				remove_npc_slot_data_by_index(npc.npc_id, i)

func get_npc_equiped_slot_data_index_by_name(name: String) -> int:
	for npc in NpcManager.npcs:
		if npc.npc_id == npc_id or npc.npc_name == npc_name:
			for i in range(npc.inventory_data.slot_datas.size()):
				if npc.inventory_data.get_slot_data_name(i) == name:
					return i
	return -1
