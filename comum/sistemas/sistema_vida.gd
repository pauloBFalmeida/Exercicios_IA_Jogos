extends Node
class_name SistemaVida

signal atualizou_vida(vida_atual: float)

@export var pode_regenerar_vida: bool = true
## quantidade de vida ganha por segundo
@export var regenerar_vida_seg: float = 1.5

var vida : float = 100.0

func perder(quantidade: float) -> void:
	vida -= quantidade
	if vida < 0: vida = 0
	
	atualizou_vida.emit(vida)

func ganhar(quantidade: float) -> void:
	vida += quantidade
	if vida > 100: vida = 100
	
	atualizou_vida.emit(vida)

func _process(delta: float) -> void:
	if pode_regenerar_vida:
		ganhar(regenerar_vida_seg * delta)
