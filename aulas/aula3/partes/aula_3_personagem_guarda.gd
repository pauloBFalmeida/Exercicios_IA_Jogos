class_name Aula3Guarda
extends Personagem

@export var jogador: Jogador

@onready var label_3d_avisado: Label3D = $Label3D_avisado

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	look_at_horizontal(jogador.global_position)

func avisar_roubo() -> void:
	label_3d_avisado.show()
	get_tree().create_timer(5.0).timeout.connect(
		func(): label_3d_avisado.hide()
	)
