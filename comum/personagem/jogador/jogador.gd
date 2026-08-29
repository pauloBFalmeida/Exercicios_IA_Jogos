class_name Jogador
extends Personagem

@export var velocidade := 4.0
@export var velocidade_salto = 4.5

@export var dano_ataque:= 25

@export var free_cam: Freecam3D

@onready var shape_cast_ataque: ShapeCast3D = $ShapeCastAtaque
@onready var label_roubado: Label3D = $LabelRoubado

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# jogador pode se mover
	var pode_se_mover: bool = true
	# se tem free camera  E
	# se a free cam estiver no modo movimento,
	# entao jogador nao pode se mover
	if free_cam and free_cam.movement_active:
		pode_se_mover = false
	
	# se nao pode se mover nesse frame, pare aqui a funcao
	if not pode_se_mover: return
	
	# Handle jump.
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = velocidade_salto

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("esquerda", "direita", "frente", "tras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * velocidade
		velocity.z = direction.z * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0, velocidade)
		velocity.z = move_toward(velocity.z, 0, velocidade)

	move_and_slide()
	
	# input de ataque
	if Input.is_action_just_pressed("acao"):
		atacar()
		
	# input de roubo
	if Input.is_action_just_pressed("acao_2"):
		roubar()

func atacar() -> void:
	animacao_ataque()
	# shape cast para detectar ataque
	shape_cast_ataque.enabled = true
	# forca atualizar para detectar hits agora (inves de no prox physics frame)
	shape_cast_ataque.force_shapecast_update() 
	# verifica se atingiu algo
	for i in shape_cast_ataque.get_collision_count():
		var hit_body := shape_cast_ataque.get_collider(i)
		if hit_body is Personagem:
			hit_body.levar_dano(dano_ataque)

signal roubou

@onready var label_roubado_pos_y := label_roubado.position.y

func roubar() -> void:
	roubou.emit()
	label_roubado.show()
	var pos_y := label_roubado_pos_y
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		label_roubado, "position:y", 
		pos_y + 0.5, 
		1.0
	).from(pos_y)
	
	await tween.finished
	label_roubado.hide()
	label_roubado.position.y = pos_y
