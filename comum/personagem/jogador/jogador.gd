class_name Jogador
extends Personagem

@export var velocidade := 4.0
@export var velocidade_salto = 4.5

@export var free_cam: Freecam3D

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
	
