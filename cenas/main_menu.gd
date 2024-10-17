extends Control

var enet_peer = ENetMultiplayerPeer.new()
const port = 5555
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enet_peer.create_client("localhost",port)
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_pressed() -> void:
	var cena = preload("res://cenas/mapas/cena1.tscn").instantiate()
	get_tree().root.add_child(cena)
	queue_free()


func _on_host_pressed() -> void:
	$MenuBotoes.hide()
	
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_Player)



func add_Player(id):
	var pl = preload("res://cenas/players.tscn").instantiate()
	var pcb = preload("res://cenas/teste.tscn").instantiate()
	pl.text = str(id)
	add_child(pcb)
	$MenuHost/ScrollContainer/GridContainer.add_child(pl)
