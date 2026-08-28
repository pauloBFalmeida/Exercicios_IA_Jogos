class_name Aula3Mercador
extends Personagem

@export_enum("FSM", "BT") var cerebro: String

## Jogador
@export var jogador : Jogador
## Guarda
@export var guarda : Aula3Guarda

@export var waypoint_mercado : Node3D
@export var waypoint_venda : Node3D

## velocidade de movimento do mercador
@export var velocidade:= 5.0

## raio da visao mercador
@export var visao_range: int = 5

@onready var mesh_alcance_visao: MeshInstance3D = $MeshAlcanceVisao

@onready var fsm: Aula3_FSM = $FSM
@onready var bt: Aula3_BT = $BT

@onready var label_3d_titulo: Label3D = $Label3D_Titulo
@onready var label_3d_acao: Label3D = $Label3D_acao

@onready var label_3d_vender: Label3D = $Label3D_Vender
@onready var timer_vender: Timer = $Label3D_Vender/TimerVender
@onready var timer_escondido: Timer = $TimerEscondido

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
	
	_preparar_cerebro()
	# alcance da visao
	var torus_visao = mesh_alcance_visao.mesh as TorusMesh
	torus_visao.inner_radius = visao_range - 0.25
	torus_visao.outer_radius = visao_range
	torus_visao.material = material
	# vender
	timer_vender.timeout.connect(label_3d_vender.hide)
	# sistema de vida
	sistema_vida.levou_dano.connect(func(): levou_dano_ticket = true )
	#
	timer_escondido.timeout.connect(func(): passou_tempo_escondido_ticket = true )
	# 
	jogador.roubou.connect(_jogador_roubou)

func _preparar_cerebro() -> void:
	fsm.process_mode = Node.PROCESS_MODE_DISABLED
	bt.process_mode = Node.PROCESS_MODE_DISABLED
	
	if cerebro == "FSM":
		fsm.process_mode = Node.PROCESS_MODE_INHERIT
	elif cerebro == "BT":
		bt.process_mode = Node.PROCESS_MODE_INHERIT
	
	label_3d_titulo.text += " (" + cerebro + ")"


func _process(delta: float) -> void:
	# input de ataque
	if Input.is_action_just_pressed("acao"):
		vender()
	
	# TODO: melhorar avisar o guarda
	if global_position.distance_squared_to(guarda.global_position) < 4:
		guarda.avisar_roubo()
		avisou_guarda_ticket = true

func _atualizar_mostrar_acao(nome_acao: String) -> void:
	label_3d_acao.text = "acao: " + nome_acao

func _jogador_roubou() -> void:
	if jogador_dentro_visao():
		roubou_dentro_visao_ticket = true



# Acoes
# -----------------------------------------------------------------------------

func esperar() -> void:
	_atualizar_mostrar_acao("esperar")
	# ficar parado
	parar_mover()

func vender() -> void:
	_atualizar_mostrar_acao("vender")
	# olha para o jogador e fala de vender
	look_at_horizontal(jogador.global_position)
	label_3d_vender.show()
	timer_vender.start()

func relatar_roubo() -> void:
	_atualizar_mostrar_acao("relatar_roubo")
	# ir em direcao ao guarda
	var direcao := global_position.direction_to(guarda.global_position)
	mover(direcao.normalized(), velocidade)

func esconder_no_mercado() -> void:
	_atualizar_mostrar_acao("esconder")
	# ir em direcao a dentro do mercado
	var direcao := global_position.direction_to(waypoint_mercado.global_position)
	mover(direcao.normalized(), velocidade)

func ficar_escondido() -> void:
	_atualizar_mostrar_acao("escondido")
	# ficar parado
	parar_mover()
	# se o timer nao estiver contando, comece a contar
	if timer_escondido.is_stopped():
		timer_escondido.start()

func retornar_waypoint_venda() -> void:
	_atualizar_mostrar_acao("retornar venda")
	# ir em direcao a ao local de venda (frente do mercado)
	var direcao := global_position.direction_to(waypoint_venda.global_position)
	mover(direcao.normalized(), velocidade)
	
func fugir() -> void:
	_atualizar_mostrar_acao("fugir")
	var direcao = global_position.direction_to(jogador.global_position)
	# direcao horizontal oposta do jogador
	direcao.x = -direcao.x
	direcao.z = -direcao.z
	mover(direcao, velocidade)


# Condicoes
# -----------------------------------------------------------------------------

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
	var distancia := global_position.distance_to(waypoint_mercado.global_position)
	return distancia < 1

func esta_ponto_venda() -> bool:
	var distancia := global_position.distance_to(waypoint_venda.global_position) 
	return distancia < 1
