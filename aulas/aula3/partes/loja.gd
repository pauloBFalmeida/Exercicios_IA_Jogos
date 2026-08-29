class_name Aula3Loja
extends Node3D

signal mercador_ficou_tempo_na_loja

## Tempo necessario em segundos que o mercador deve ficar dentro da loja
@export var mercador_tempo_necessario_dentro_loja := 10.0 

@onready var area_3d: Area3D = $WaypointInteriorLoja/Area3D
@onready var label_tempo_loja: Label3D = $LabelTempoLoja

var mercador_tempo_dentro_loja := 0.0
var mercador_esta_dentro_loja := false

func _ready() -> void:
	label_tempo_loja.hide()
	area_3d.body_entered.connect(_on_area_body_entered)
	area_3d.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node3D) -> void:
	if body is Aula3Mercador:
		mercador_tempo_dentro_loja = 0.0
		mercador_esta_dentro_loja = true

func _on_area_body_exited(body: Node3D) -> void:
	if body is Aula3Mercador:
		mercador_tempo_dentro_loja = 0.0
		mercador_esta_dentro_loja = false


func _process(delta: float) -> void:
	label_tempo_loja.hide()
	
	if mercador_esta_dentro_loja:
		mercador_tempo_dentro_loja += delta
		if mercador_tempo_dentro_loja > mercador_tempo_necessario_dentro_loja:
			mercador_ficou_tempo_na_loja.emit()
		# mostrar tempo
		label_tempo_loja.text = "Tempo Dentro Loja:\n%.1f seg" %  mercador_tempo_dentro_loja
		label_tempo_loja.show()
