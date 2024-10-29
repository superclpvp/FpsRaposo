extends Node

const  Player = preload("res://cenas/player/player.tscn")
const port = 5555
var enet_peer = ENetMultiplayerPeer.new()

var players_id = []

func _ready() -> void:
	#add_player(multiplayer.get_unique_id())
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("sair"):
		get_tree().quit()



func add_player(id):
	for i in players_id.size():
		rpc_id(players_id[i],"adicionar_Player",id)
	$Camera3D.current = false
	$Camera3D/Hud.hide()
	var player = Player.instantiate()
	player.name = str(id)
	player.players = players_id
	add_child(player)

func remove_player(id):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()



#func upnp_setup():
	#var upnp = UPNP.new()
	#
	#var discover_result = upnp.discover()
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS,"UPNP Discover Failed! Error %s" % discover_result)
#
	#assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
#
	#var map_result = upnp.add_port_mapping(port)
	#assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP PORT mapping Failed! Error %s" % map_result)
	#
	#print("sucesso! entre nesse endereço ", upnp.query_external_address())


func _on_ct_pressed() -> void:
	add_player(multiplayer.get_unique_id())


@rpc("any_peer")
func adicionar_Player(id):
	print("addPlayer")
	var player = Player.instantiate()
	player.find_child("VidaBarra").hide()
	player.find_child("Mira").hide()
	player.name = str(id)
	add_child(player)
