class_name Aula3Mercador
extends Personagem

@export_enum("FSM", "BT") var cerebro: String

## Jogador
@export var jogador : Jogador
## Guarda
@export var guarda : Aula3Guarda
@export var loja : Aula3Loja

@export var waypoint_loja : Node3D
@export var waypoint_venda : Node3D

## velocidade de movimento do mercador
@export var velocidade:= 5.0

## raio da visao mercador
@export var visao_range: int = 5

@onready var mesh_alcance_visao: MeshInstance3D = $MeshAlcanceVisao

@onready var fsm: Aula3_FSM = $FSM
@onready var bt: Aula3_BT = $BT

@onready var item_list_cerebros: ItemList = $ItemListCerebros

@onready var label_3d_titulo: Label3D = $Label3D_Titulo
@onready var label_3d_acao: Label3D = $Label3D_acao

@onready var label_3d_vender: Label3D = $Label3D_Vender
@onready var timer_vender: Timer = $Label3D_Vender/TimerVender

# TODO:
# ao vender ele fica esperando só 2 condicoes, tem q colocar todas

## Cada vez que leva dano no sistema de vida, o ticket marca como true, ate ser consumido
# TODO: o ticket fica e apos retornar ele foge
var levou_dano_ticket: bool = false

var roubou_dentro_visao_ticket: bool = false

var avisou_guarda_ticket: bool = false

var passou_tempo_escondido_ticket: bool = false


func _ready() -> void:
	super()
	
	_preparar_cerebro(cerebro)
	# alcance da visao
	var torus_visao = mesh_alcance_visao.mesh as TorusMesh
	torus_visao.inner_radius = visao_range - 0.25
	torus_visao.outer_radius = visao_range
	torus_visao.material = material
	# vender
	timer_vender.timeout.connect(label_3d_vender.hide)
	# sistema de vida
	sistema_vida.levou_dano.connect(func(): levou_dano_ticket = true )
	# tempo suficiente escondido
	loja.mercador_ficou_tempo_na_loja.connect(func(): passou_tempo_escondido_ticket = true )
	# jogador roubou
	jogador.roubou.connect(_jogador_roubou)

func _preparar_cerebro(_cerebro: String) -> void:
	# atualiza o cerebro
	cerebro = _cerebro
	# desliga ambos
	fsm.process_mode = Node.PROCESS_MODE_DISABLED
	bt.process_mode = Node.PROCESS_MODE_DISABLED
	# liga o que for usar
	if cerebro == "FSM":
		fsm.process_mode = Node.PROCESS_MODE_INHERIT
	elif cerebro == "BT":
		bt.process_mode = Node.PROCESS_MODE_INHERIT
	# atualiza o titulo do personagem com o nome do cerebro em uso
	label_3d_titulo.text = "Mercador (%s)" % cerebro

func _on_item_list_cerebros_item_selected(index: int) -> void:
	# pega o texto do item selecionado
	var texto := item_list_cerebros.get_item_text(index)
	# pega a primeira palavra do item selecionado
	var _cerebro: String = texto.split(" ")[0]
	_preparar_cerebro(_cerebro)

func _process(_delta: float) -> void:	
	# TODO: melhorar avisar o guarda
	if esta_perto_objeto(guarda, 4):
		guarda.avisar_roubo()
		avisou_guarda_ticket = true


func _atualizar_mostrar_acao(nome_acao: String, cor_acao: Color = Color.WHITE) -> void:
	label_3d_acao.text = "acao: " + nome_acao
	label_3d_acao.modulate = cor_acao
	# TODO: lugar melhor
	esta_escodendo_atualmente = false
	esta_fugindo_atualmente   = false
	esta_relatando_atualmente = false

func _jogador_roubou() -> void:
	if jogador_dentro_visao():
		roubou_dentro_visao_ticket = true

# Acoes
# -----------------------------------------------------------------------------

func esperar() -> void:
	_atualizar_mostrar_acao("esperar", Color.CORAL)
	# ficar parado
	parar_mover()

func vender() -> void:
	_atualizar_mostrar_acao("vender", Color.GOLD)
	# ficar parado
	parar_mover()
	# olha para o jogador e fala de vender
	look_at_horizontal(jogador.global_position)
	label_3d_vender.show()
	timer_vender.start()

func relatar_roubo() -> void:
	_atualizar_mostrar_acao("relatar_roubo", Color.DEEP_SKY_BLUE)
	esta_relatando_atualmente = true
	# ir em direcao ao guarda
	mover_direcao_objeto(guarda, velocidade)

func esconder_no_mercado() -> void:
	_atualizar_mostrar_acao("esconder", Color.GREEN_YELLOW)
	esta_escodendo_atualmente = true
	# ir em direcao a dentro do mercado
	mover_direcao_objeto(waypoint_loja, velocidade)

func ficar_escondido() -> void:
	_atualizar_mostrar_acao("escondido", Color.WEB_GREEN)
	# ficar parado
	parar_mover()

func retornar_waypoint_venda() -> void:
	_atualizar_mostrar_acao("retornar venda", Color.MEDIUM_VIOLET_RED)
	# ir em direcao a ao local de venda (frente do mercado)
	mover_direcao_objeto(waypoint_venda, velocidade)

func fugir() -> void:
	_atualizar_mostrar_acao("fugir", Color.FIREBRICK)
	esta_fugindo_atualmente = true
	mover_direcao_oposta_objeto(jogador, velocidade)


# Condicoes
# -----------------------------------------------------------------------------

var esta_escodendo_atualmente: bool = false
var esta_fugindo_atualmente: bool = false
var esta_relatando_atualmente: bool = false

func esta_escondendo() -> bool:
	return esta_escodendo_atualmente
func esta_fugindo() -> bool:
	return esta_fugindo_atualmente
func esta_relatando() -> bool:
	return esta_relatando_atualmente

## Mercador tem menos de 30% de vida
func pouca_vida() -> bool:
	return sistema_vida.vida <= 30

## Mercador tem mais de 50% de vida
func muita_vida() -> bool:
	return sistema_vida.vida >= 50

## Jogador esta dentro da area de visao
func jogador_dentro_visao() -> bool:
	var distancia := global_position.distance_to(jogador.global_position) 
	return distancia < visao_range

## Jogador esta fora da area de visao
func jogador_fora_visao() -> bool:
	return not jogador_dentro_visao()

## Mercador teve algo roubado dentro da area de visao
func roubo_dentro_visao() -> bool:
	# se aconteceu, consome o ticket
	if roubou_dentro_visao_ticket:
		roubou_dentro_visao_ticket = false
		return true
	# se nao levou dano
	return false

func levou_dano() -> bool:
	# se levou dano, consome o ticket
	if levou_dano_ticket:
		levou_dano_ticket = false
		return true
	# se nao levou dano
	return false

func avisou_guarda() -> bool:
	# se avisou o guarda, consome o ticket
	if avisou_guarda_ticket:
		avisou_guarda_ticket = false
		return true
	# se nao levou dano
	return false

func passou_tempo_escondido() -> bool:
	# se esperou tempo o suficiente, consome o ticket
	if passou_tempo_escondido_ticket:
		passou_tempo_escondido_ticket = false
		return true
	# se nao levou dano
	return false

func esta_dentro_mercado() -> bool:
	return esta_perto_objeto(waypoint_loja)

func esta_ponto_venda() -> bool:
	return esta_perto_objeto(waypoint_venda)
