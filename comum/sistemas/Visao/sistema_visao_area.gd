class_name SistemaVisaoArea
extends SistemaVisao

@onready var mesh_alcance_visao: MeshInstance3D = $MeshAlcanceVisao

func _ready() -> void:
	# alcance da visao
	ajustar_raio_visao(visao_range)
	# tenta pegar o material do pai se for personagem
	var pai : Node = get_parent()
	if pai is Personagem:
		await get_tree().physics_frame
		set_material(pai.material)

func ajustar_raio_visao(tamanho_raio: int) -> void:
	visao_range = tamanho_raio
	var torus_visao = mesh_alcance_visao.mesh as TorusMesh
	torus_visao.inner_radius = visao_range - 0.25
	torus_visao.outer_radius = visao_range

func set_material(material: Material) -> void:
	mesh_alcance_visao.mesh.material = material


## Retorna true se o obj esta dentro do visao_range
func esta_dentro_visao(obj: Node3D) -> bool:
	var distancia := global_position.distance_squared_to(obj.global_position)
	return distancia < visao_range_pow
	# # Esse codigo seria equivalente, mas essa de cima eh mais eficiente
	#var distancia := global_position.distance_to(jogador.global_position) 
	#return distancia < visao_range
