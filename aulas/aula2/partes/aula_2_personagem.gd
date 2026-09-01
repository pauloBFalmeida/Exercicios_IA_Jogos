class_name Aula2Personagem
extends Personagem

## Outro personagem que vai estar em combate
@export var outro_personagem : Personagem

@export_category("Configuracoes dos Estados")
## distancia maxima que o waypoint de patrulha vai ser criado partindo do spawn: posicao (0,0,0)
@export var patrulhar_distancia_spawn 	:= 20
## se a vida estiver inferior a esse valor, fugir
@export var fugir_threshold_vida		:= 40
## distancia que pode atacar o outro personagem
@export var ataque_range				:= 2
## distancia maxima que vai perseguir outro personagem 
@export var perseguir_range 			:= 15

@export_category("Velocidades")
@export var velocidade_fugir := 5.0
@export var velocidade_perseguir := 3.0
@export var velocidade_patrulhar := 4.0

@onready var label_acao: Label3D = $Label3D_acao

@onready var sistema_visao_area: SistemaVisaoArea = $SistemaVisaoArea

@onready var sphere_waypoint_patrulha: CSGSphere3D = $MostrarWaypointPatrulha/Sphere3D

var waypoint_patrulhar: Vector3 = Vector3.INF
# ataque esta pronto para ser usado
var ataque_esta_pronto : bool = true
## Cooldown entre 2 ataques, tempo minimo para atacar novamente
var cooldown_ataque := 2.0

## Estados da FSM (Maquina de Estados Finita) que o personagem pode ter
enum Estado { PATRULHAR, PERSEGUIR, ATACAR, FUGIR }
var estado_atual = Estado.PATRULHAR

## Cor para cada estado (para mostrar
const cor_estado := {
	Estado.PATRULHAR: 	Color.YELLOW,
	Estado.PERSEGUIR:  	Color.LAWN_GREEN,
	Estado.ATACAR: 		Color.DEEP_PINK,
	Estado.FUGIR:   		Color.STEEL_BLUE
}

func _ready() -> void:
	# faz o ready da classe pai (extends Personagem)
	super()
	# waypoint de patrulha
	sphere_waypoint_patrulha.material = material
	# alcance da visao
	sistema_visao_area.ajustar_raio_visao(perseguir_range)


func _process(_delta: float) -> void:
	var distancia = global_position.distance_to(outro_personagem.global_position)

	# Logica de qual sera o proximo estado
	if sistema_vida.vida <= fugir_threshold_vida:
		estado_atual = Estado.FUGIR
	elif distancia <= ataque_range:
		estado_atual = Estado.ATACAR
	elif distancia <= perseguir_range:
		estado_atual = Estado.PERSEGUIR
	else:
		estado_atual = Estado.PATRULHAR

	# Executa o estado atualizado
	match estado_atual:
		Estado.PATRULHAR:	patrulhar()
		Estado.PERSEGUIR:	perseguir()
		Estado.ATACAR:		atacar()
		Estado.FUGIR:		fugir()
	
	# Atualiza o texto de qual acao o personagem esta fazendo para o nome do estado
	var nome_estado_atual = Estado.find_key(estado_atual)
	label_acao.text = "acao: " + nome_estado_atual
	label_acao.modulate = cor_estado[estado_atual]
	
	# Mostra o alcance da visao se for Patrulha ou Perseguir
	if estado_atual in [Estado.PATRULHAR, Estado.PERSEGUIR]:
		sistema_visao_area.show()
	else:
		sistema_visao_area.hide()
	# Mostra o waypoint se for Patrulha
	if estado_atual == Estado.PATRULHAR:
		sphere_waypoint_patrulha.show()
	else:
		sphere_waypoint_patrulha.hide()


func patrulhar():
	# se nao tiver uma posicao para waypoint, crie um
	if waypoint_patrulhar == Vector3.INF:
		_posicionar_waypoint_patrulha()
	
	# se tiver chego no waypoint
	if esta_perto_posicao_global(waypoint_patrulhar):
		# remove o waypoint atual
		waypoint_patrulhar = Vector3.INF
		# para de se mover
		parar_mover()
		return
	
	# anda na direcao do waypoint
	mover_direcao_posicao_global(waypoint_patrulhar, velocidade_patrulhar)

func _posicionar_waypoint_patrulha() -> void:
	# posicao do waypoint proximo do spawn
	waypoint_patrulhar = Vector3(
		randf_range(-patrulhar_distancia_spawn, patrulhar_distancia_spawn),
		0,
		randf_range(-patrulhar_distancia_spawn, patrulhar_distancia_spawn),
	)
	# posiciona
	sphere_waypoint_patrulha.global_position = waypoint_patrulhar

func perseguir():
	mover_direcao_objeto(outro_personagem, velocidade_perseguir)

func atacar():
	parar_mover()
	
	# se o ataque nao estiver pronto, nao continue
	if not ataque_esta_pronto: return
	# gasta o ataque
	ataque_esta_pronto = false
	# espera bater na animacao de ataque
	await animacao_ataque()
	# dar dano 
	var quantidade := randi_range(10, 25) # dano aleatorio de 10 a 25
	outro_personagem.levar_dano(quantidade)
	
	# espera o cooldown para poder atacar de novo
	get_tree().create_timer(cooldown_ataque).timeout.connect(
		func(): ataque_esta_pronto = true
	)

func fugir():
	mover_direcao_oposta_objeto(outro_personagem, velocidade_fugir)
