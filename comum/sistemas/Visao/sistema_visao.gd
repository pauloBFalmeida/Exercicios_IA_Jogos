@abstract
class_name SistemaVisao
extends Node3D

signal entrou_dentro_visao(obj: Node3D)
signal saiu_dentro_visao(obj: Node3D)

## raio da visao
@export var visao_range: int = 5 :
	set(_visao_range):
		visao_range = _visao_range
		visao_range_pow = _visao_range * _visao_range

## visao range ao quadrado para calculo eficiente de distancia
@onready var visao_range_pow := visao_range * visao_range

## Lista de nodos que estao sendo escaneados
var nodos_lista_aviso: Array[Node3D] = []
## Lista de nodo escaneados que estao atualmente dentro do alcance da visao
var nodos_aviso_atualmente_dentro_visao: Array[Node3D] = []

## Retorna true se o obj esta dentro do visao_range
@abstract
func esta_dentro_visao(obj: Node3D) -> bool

# Avisar ao entrar e sair da visao
# -----------------------------------------------------------------------------

## Guarda o nodo passado e avisa ao quando aquele nodo entrar ou sair da visao
func avisar_ao_entrar_visao(obj: Node3D) -> void:
	nodos_lista_aviso.append(obj)

func _physics_process(_delta: float) -> void:
	for obj : Node3D in nodos_lista_aviso:
		if esta_dentro_visao(obj):
			# nao estava dentro da visao, entao entrou agora
			if not nodos_aviso_atualmente_dentro_visao.has(obj):
				_entrou_visao(obj)
		else:
			# estava dentro da visao, entao saiu agora
			if nodos_aviso_atualmente_dentro_visao.has(obj):
				_saiu_visao(obj)

## Obj acabou de entrar na visao
func _entrou_visao(obj: Node3D) -> void:
	# marca que esta sendo visto
	nodos_aviso_atualmente_dentro_visao.append(obj)
	# avisa
	entrou_dentro_visao.emit(obj)

## Obj acabou de sair da visao
func _saiu_visao(obj: Node3D) -> void:
	# marca que esta nao esta mais sendo visto
	nodos_aviso_atualmente_dentro_visao.erase(obj)
	# avisa
	saiu_dentro_visao.emit(obj)
