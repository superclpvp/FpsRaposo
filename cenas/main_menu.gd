extends Control

var procurando_sala = false
var dentro_sala = false

var dado_sala = []
var dono_da_sala = false

var salas
var Numero_salas
var NovoNsala

func _on_join_pressed() -> void:
	$menu.hide()
	$"opçoesDeJogo".show()

func _process(delta: float) -> void:
	if multiplayer.get_multiplayer_peer().get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		$menu/Label.text = "desconectado"
	elif multiplayer.get_multiplayer_peer().get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		$menu/Label.text = "conectando..."
	elif multiplayer.get_multiplayer_peer().get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		$menu/Label.text = str("conectado ")
	
	
	
	if procurando_sala:
		if $Procurar.is_stopped():
			$Procurar.start()
		NovoNsala = Client.Numero_salas
		salas = Client.salas
		var count = $"Ver Sala/ScrollContainer/GridContainer".get_child_count()
		if count != null:
			for i in $"Ver Sala/ScrollContainer/GridContainer".get_children():
				if i.entrar:
					Client.entrarNaSala(i.get_child(1).text)
					print("entrar na sala ",i.get_child(1).text)
					procurando_sala = false
					entrar_sala()
					break
		
		#print("sala ",NovoNsala, " sala2 ",Numero_salas)
		
		if Numero_salas != NovoNsala:
			Numero_salas = Client.Numero_salas
			for i in $"Ver Sala/ScrollContainer/GridContainer".get_child_count():
				$"Ver Sala/ScrollContainer/GridContainer".get_child(i).queue_free()
			if Numero_salas != null:
				for i in Numero_salas:
					var sala_I = preload("res://cenas/Multiplayer/sala.tscn").instantiate()
					$"Ver Sala/ScrollContainer/GridContainer".add_child(sala_I)
					sala_I.get_child(1).text = str(salas[i][0])
					sala_I.get_child(2).text = str(salas[i][1][0])
					sala_I.name = str(salas[i][0])
					print("nome da sala ",salas[i][0])
	else:
		$Procurar.stop()
	
	if dentro_sala:
		if Client.sair_sala_bool:
			$menu.show()
			$sala.hide()
			dentro_sala = false
			dado_sala = []
			procurando_sala = false
			Client.sair_sala_bool = false
			print("sair")
		if dono_da_sala:
			$sala/Dono.show()
		else:
			$sala/naoDono.show()
		
		if Client.dado_sala != null:
			if Client.dado_sala != dado_sala:
				print("mudou")
				for s in $sala/ScrollContainer/GridContainer.get_children():
					s.queue_free()
				for i in Client.dado_sala[0]:
					var playsala = preload("res://cenas/Multiplayer/player_sala.tscn").instantiate()
					$"sala/ScrollContainer/GridContainer".add_child(playsala)
					playsala.get_child(2).text = str(i)
				dado_sala = Client.dado_sala
	else:
		Client.sair_sala_bool = false
		$sala/Dono.hide()
		$sala/naoDono.hide()
		$sala.hide()

#var cena = preload("res://cenas/mapas/cena1.tscn").instantiate()
#get_tree().root.add_child(cena)
#queue_free()
func entrar_sala():
	$"Ver Sala".hide()
	$sala.show()
	dentro_sala = true
	NovoNsala = 0

func _on_criarsala_pressed() -> void:
	$"opçoesDeJogo".hide()
	$"sala".show()
	Client.CriarSala()
	dentro_sala = true
	dono_da_sala = true
	
	

func _on_entrar_em_uma_pressed() -> void:
	$"opçoesDeJogo".hide()
	$"Ver Sala".show()
	Client.pedirSala()
	procurando_sala = true


func _on_procurar_timeout() -> void:
	Client.pedirSala()


func _on_sairda_sala_pressed() -> void:
	Client.cliente_sair_sala()


func _on_fechar_sala_pressed() -> void:
	Client.fechar_sala()
