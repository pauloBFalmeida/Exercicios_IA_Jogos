extends Control

## Para cada cena de exercicio tem uma descricao
@export var exercicios_descricao : Dictionary[PackedScene, String]

@onready var grid_container: GridContainer = $MeioSize/GridSize/GridContainer

func _ready() -> void:
	for cena in exercicios_descricao.keys():
		var txt := exercicios_descricao[cena]
		var btn := Button.new()
		btn.text = txt
		btn.pressed.connect(
			func(): get_tree().change_scene_to_packed(cena)
		)
		# adiciona na grid
		grid_container.add_child(btn)

func _on_button_sair_pressed() -> void:
	get_tree().quit()
