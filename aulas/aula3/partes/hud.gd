extends Control

@export var free_cam: Freecam3D
## Nodo pai de toda a cena
@export var cena: Node

@onready var button_cam_seguir_jog: Button = $ButtonCamSeguirJog

const button_cam_texto := "Camera Seguindo Jogador: "
## camera temporaria fixa no mapa
var temp_cam: Camera3D

func _on_button_cam_seguir_jog_toggled(toggled_on: bool) -> void:
	# atualiza o texto da camera
	button_cam_seguir_jog.text = button_cam_texto + ("On" if toggled_on else "Off")
	# se estiver para seguir o jogador
	if toggled_on:
		free_cam.make_current()
		# deleta a camera temporaria se existir
		if temp_cam:
			temp_cam.queue_free()
	# se estiver para ficar no mapa
	else:
		# cria uma camera normal temporaria
		temp_cam = Camera3D.new()
		cena.add_child(temp_cam)
		temp_cam.global_transform = free_cam.global_transform
		temp_cam.make_current()
