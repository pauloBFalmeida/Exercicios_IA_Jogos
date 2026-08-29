class_name Aula3JogadorLadrao
extends Jogador

signal roubou

@export var dano_ataque:= 25

@onready var shape_cast_ataque: ShapeCast3D = $ShapeCastAtaque

@onready var label_roubado: Label3D = $LabelRoubado
@onready var label_roubado_pos_y := label_roubado.position.y

func _ready() -> void:
	super()
	label_roubado.hide()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# input de ataque
	if Input.is_action_just_pressed("acao"):
		atacar()
		
	# input de roubo
	if Input.is_action_just_pressed("acao_2"):
		roubar()

func atacar() -> void:
	await animacao_ataque()
	# shape cast para detectar ataque
	shape_cast_ataque.enabled = true
	# forca atualizar para detectar hits agora (inves de no prox physics frame)
	shape_cast_ataque.force_shapecast_update() 
	# verifica se atingiu algo
	for i in shape_cast_ataque.get_collision_count():
		var hit_body := shape_cast_ataque.get_collider(i)
		if hit_body is Personagem:
			hit_body.levar_dano(dano_ataque)
	# desativa o shape cast depois de verificar
	shape_cast_ataque.enabled = false

func roubar() -> void:
	# emite o sinal que roubou (isso que realmente importa para coisas reagirem)
	roubou.emit()
	# mostra o label para o jogador saber que aconteceu algo
	label_roubado.show()
	# faz a label subir (como se tivesse pego algo)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		label_roubado, "position:y", 
		label_roubado_pos_y + 0.5, 
		1.0
	).from(label_roubado_pos_y) # inicia da altura inicial, (sem isso cada animacao vai mudar a posicao)
	# quando terminar o efeito, esconde a label
	await tween.finished
	label_roubado.hide()
