class_name Aula3_FSM
extends Node

@export var mercador: Aula3Mercador

enum Estado { ESPERAR, VENDER, RELATAR, ESCONDER, ESCONDIDO, RETORNAR, FUGIR }
var estado_atual = Estado.ESPERAR

func _process(delta):
	match estado_atual:
		Estado.ESPERAR:
			executar_esperar()
		Estado.VENDER:
			executar_vender()
		Estado.RELATAR:
			executar_relatar()
		Estado.ESCONDER:
			executar_esconder()
		Estado.ESCONDIDO:
			executar_escondido()
		Estado.RETORNAR:
			executar_retornar()
		Estado.FUGIR:
			executar_fugir()

func executar_esperar():
	# comportamento do estado "Esperar"
	mercador.esperar()
	# troca de estados
	if condicao_vidamenorque30():
		estado_atual = Estado.FUGIR
	if condicao_jogadordentrovista():
		estado_atual = Estado.VENDER
	if condicao_roubodentrovista():
		estado_atual = Estado.RELATAR
	if condicao_recebeudano():
		estado_atual = Estado.ESCONDER

func executar_vender():
	# comportamento do estado "Vender"
	mercador.vender()
	# troca de estados
	if condicao_vidamenorque30():
		estado_atual = Estado.FUGIR
	if condicao_jogadorforavista():
		estado_atual = Estado.ESPERAR

func executar_relatar():
	# comportamento do estado "Relatar"
	mercador.relatar_roubo()
	# troca de estados
	if condicao_vidamenorque30():
		estado_atual = Estado.FUGIR
	if condicao_avisouguarda():
		estado_atual = Estado.RETORNAR

func executar_esconder():
	# comportamento do estado "Esconder"
	mercador.esconder_no_mercado()
	# troca de estados
	if condicao_vidamenorque30():
		estado_atual = Estado.FUGIR
	if condicao_estadentromercado():
		estado_atual = Estado.ESCONDIDO

func executar_escondido():
	# comportamento do estado "Escondido"
	mercador.ficar_escondido()
	# troca de estados
	if condicao_escondidopor10segundos():
		estado_atual = Estado.RETORNAR

func executar_retornar():
	# comportamento do estado "Retornar"
	mercador.retornar_waypoint_venda()
	# troca de estados
	if condicao_vidamenorque30():
		estado_atual = Estado.FUGIR
	if condicao_estapontodevenda():
		estado_atual = Estado.ESPERAR

func executar_fugir():
	# comportamento do estado "Fugir"
	mercador.fugir()
	# troca de estados
	if condicao_vidamaiorque50():
		estado_atual = Estado.RETORNAR

func condicao_vidamenorque30():
	# condicao: "vida menor que 30%"
	return mercador.pouca_vida()

func condicao_jogadordentrovista():
	# condicao: "jogador dentro vista"
	return mercador.jogador_dentro_visao()

func condicao_roubodentrovista():
	# condicao: "roubo dentro vista"
	return mercador.roubo_dentro_visao()

func condicao_recebeudano():
	# condicao: "recebeu dano"
	return mercador.levou_dano()

func condicao_jogadorforavista():
	# condicao: "jogador fora vista"
	return mercador.jogador_fora_visao()

func condicao_avisouguarda():
	# condicao: "avisou guarda"
	return mercador.avisou_guarda()

func condicao_estadentromercado():
	# condicao: "esta dentro mercado"
	return mercador.esta_dentro_mercado()

func condicao_escondidopor10segundos():
	# condicao: "depois de 10 segundos"
	return mercador.passou_tempo_escondido()

func condicao_estapontodevenda():
	# condicao: "esta ponto de venda"
	return mercador.esta_ponto_venda()

func condicao_vidamaiorque50():
	# condicao: "vida maior que 50%"
	return mercador.muita_vida()
