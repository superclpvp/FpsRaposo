extends Node

var enet_peer = ENetMultiplayerPeer.new()
const port = 2222

var dado_sala = []
var mudou = false

var sair_sala_bool = false

var salas
var Numero_salas

func _ready() -> void:
	var result = enet_peer.create_client("179.48.48.6",port)
	multiplayer.multiplayer_peer = enet_peer

func _process(delta: float):
	pass

#region comunicacao app para client

func entrarNaSala(nome):
	rpc_id(1,"entrar_na_sala",nome,multiplayer.get_unique_id())

func CriarSala():
	rpc_id(1,"criar_Sala",multiplayer.get_unique_id())

func pedirSala():
	rpc_id(1,"cliente_pedindo_sala",multiplayer.get_unique_id())

func cliente_sair_sala():
	sair_sala_bool = true
	dado_sala = []
	print("sair")
	rpc_id(1,"cliente_sair_da_sala",multiplayer.get_unique_id())

func fechar_sala():
	sair_sala_bool = true
	dado_sala = []
	rpc_id(1,"pedindo_fechar_sala",multiplayer.get_unique_id())

#endregion


#region rpc do client
@rpc("any_peer")
func PegarSalas(dados,Nsalas):
	salas = dados
	Numero_salas = Nsalas
	print(salas)

@rpc("any_peer")
func dadosSala(dados):
	dado_sala = dados
	mudou = true
	print("dados ",dados)

@rpc("any_peer")
func sair_sala():
	sair_sala_bool = true
	dado_sala = []
	print("sair")

#endregion


#region rpc do server
@rpc("any_peer")
func pedindo_fechar_sala(id):
	pass


@rpc("any_peer")
func cliente_sair_da_sala(id):
	pass

@rpc("any_peer","reliable")
func entrar_na_sala(nome,id):
	pass

@rpc("any_peer")
func receber_msg(mensagem):
	pass

@rpc("any_peer")
func criar_Sala(id):
	pass

@rpc("any_peer")
func cliente_pedindo_sala(id):
	pass
#endregion
