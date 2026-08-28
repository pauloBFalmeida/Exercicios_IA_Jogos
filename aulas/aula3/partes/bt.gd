class_name Aula3_BT
extends Node

@export var mercador: Aula3Mercador

enum Status { SUCCESS, FAILURE, RUNNING }

class BTNode:
	func tick():
		return Status.FAILURE

class Selector extends BTNode:
	var filhos = []
	func _init(f):
		filhos = f
	func tick():
		for filho in filhos:
			var status = filho.tick()
			if status != Status.FAILURE:
				return status
		return Status.FAILURE

class Sequence extends BTNode:
	var filhos = []
	var seq_nome: String
	func _init(f, n):
		filhos = f
		seq_nome = n
	func tick():
		for filho in filhos:
			var status = filho.tick()
			if status != Status.SUCCESS:
				return status
		return Status.SUCCESS

class Inverter extends BTNode:
	var filho
	func _init(f):
		filho = f
	func tick():
		var status = filho.tick()
		if status == Status.SUCCESS:
			return Status.FAILURE
		if status == Status.FAILURE:
			return Status.SUCCESS
		return status

class ConditionNode extends BTNode:
	var condicao_func
	func _init(c):
		condicao_func = c
	func tick():
		return Status.SUCCESS if condicao_func.call() else Status.FAILURE

class ActionNode extends BTNode:
	var acao_func
	var acao_nome: String
	func _init(a, n):
		acao_func = a
		acao_nome = n
	func tick():
		return acao_func.call()

var raiz

func _ready():
	raiz = Selector.new([
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_vidamenorque30")), 
			ActionNode.new(Callable(self, "acao_fugir"), "acao_fugir")],
			"vida baixa"),
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_vidamaiorque50")), 
			ActionNode.new(Callable(self, "acao_retornar"), "acao_retornar")],
			"vida alta"),
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_jogadordentrovista")), 
			ActionNode.new(Callable(self, "acao_vender"), "acao_vender")],
			"viu jogador"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_jogadorforavista")), 
			ActionNode.new(Callable(self, "acao_esperar"), "acao_esperar")],
			"jogador sumiu"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_roubodentrovista")), 
			ActionNode.new(Callable(self, "acao_relatar"), "acao_relatar")],
			"viu roubo"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_recebeudano")), 
			ActionNode.new(Callable(self, "acao_esconder"), "acao_esconder")],
			"se esconder no mercado"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_estadentromercado")), 
			ActionNode.new(Callable(self, "acao_retornar"), "acao_retornar")],
			"chegou no mercado"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_avisouguarda")), 
			ActionNode.new(Callable(self, "acao_retornar"), "acao_retornar")],
			"retornar ao ponto"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_escondidopor10segundos")), 
			ActionNode.new(Callable(self, "acao_retornar"), "acao_retornar")],
			"retornar ao ponto"),  
		Sequence.new([
			ConditionNode.new(Callable(self, "condicao_estapontodevenda")), 
			ActionNode.new(Callable(self, "acao_esperar"), "acao_esperar")],
			"chegou no ponto"), 
		ActionNode.new(Callable(self, "acao_esperar"), "acao_esperar")])

func _process(delta):
	raiz.tick()

func condicao_vidamenorque30():
	# condicao: "vida menor que 30%"
	return mercador.pouca_vida()

func acao_fugir():
	# acao: "Fugir"
	mercador.fugir()
	return Status.SUCCESS

func condicao_vidamaiorque50():
	# condicao: "vida maior que 50%"
	return mercador.muita_vida()

func acao_retornar():
	# acao: "Retornar"
	mercador.retornar_waypoint_venda()
	return Status.SUCCESS

func condicao_jogadordentrovista():
	# condicao: "jogador dentro vista"
	return mercador.jogador_dentro_visao()

func acao_vender():
	# acao: "Vender"
	mercador.vender()
	return Status.SUCCESS

func condicao_jogadorforavista():
	# condicao: "jogador fora vista"
	return mercador.jogador_fora_visao()

func acao_esperar():
	# acao: "Esperar"
	mercador.esperar()
	return Status.SUCCESS

func condicao_roubodentrovista():
	# condicao: "roubo dentro vista"
	return mercador.roubo_dentro_visao()

func acao_relatar():
	# acao: "Relatar"
	mercador.relatar_roubo()
	return Status.SUCCESS

func condicao_recebeudano():
	# condicao: "recebeu dano"
	return mercador.levou_dano()

func acao_esconder():
	# acao: "Esconder"
	mercador.esconder_no_mercado()
	return Status.SUCCESS

func condicao_estadentromercado():
	# condicao: "esta dentro mercado"
	return mercador.esta_dentro_mercado()

func condicao_avisouguarda():
	# condicao: "avisou guarda"
	return mercador.avisou_guarda()

func condicao_escondidopor10segundos():
	# condicao: "escondido por 10 segundos"
	return mercador.passou_tempo_escondido()

func condicao_estapontodevenda():
	# condicao: "esta ponto de venda"
	print(mercador.esta_ponto_venda())
	return mercador.esta_ponto_venda()
