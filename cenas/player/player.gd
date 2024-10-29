extends CharacterBody3D

@onready var camera = $Camera3D
@onready var animation = $AnimationPlayer
@onready var muzzeflash = $Camera3D/Armas/pistola/GPUParticles3D
@onready var raycast = $Camera3D/RayCast3D

var vida = 3
var players = []

var Meu_ping = 10

const SPEED = 10
const JUMP_VELOCITY = 10

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): 
		print("nao sou eu")
		$Camera3D/PlayerSingle.hide()
		$PlayerModel.show()
	else:
		$Camera3D/PlayerSingle.show()
		$PlayerModel.hide()
		print("sou eu")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	
	if Input.is_action_just_pressed("dev"):
		vida -= 1
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if Input.is_action_just_pressed("atirar") and animation.current_animation != "Tiro_Pist_1": 
		#rpc("play_shoot_effects")
		play_shoot_effectsLocal()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			if hit_player and hit_player.has_method("recebe_Dano"):
				hit_player.recebe_Dano.rpc_id(hit_player.get_multiplayer_authority())
				print("player")
			else:
				var buraco = preload("res://cenas/efeitos/buracoDeBala.tscn").instantiate()
				get_parent().add_child(buraco)
				buraco.position = raycast.get_collision_point()
				var normal = raycast.get_collision_normal()
				buraco.look_at(buraco.global_transform.origin + normal,Vector3.UP)
				if normal != Vector3.UP and normal != Vector3.DOWN:
					buraco.rotate_object_local(Vector3(1,0,0), 90)
				await get_tree().create_timer(3).timeout
				buraco.queue_free()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	$Camera3D/ping.text = str("ping ", int(Meu_ping * 10))
	
	$Camera3D/VidaBarra.value = vida
	# Add the gravity.
	if not is_on_floor():
		velocity += Vector3(0,-15,0) * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if animation.current_animation == "Tiro_Pist_1":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		#animation.play("Andando_Pist_1")
		pass
	else:
		#animation.play("Idle_Pist_1")
		pass
	
	move_and_slide()

var last_ping_time: float  



@rpc("any_peer","unreliable")
func sincronizar_dados(dados):
	position = dados[1]#lerp(position,dados[1],0.1)
	rotation = dados[2]#lerp(rotation,dados[2],0.1)
	$PlayerModel/Node/Robo/Node3D.rotation = dados[3]#lerp($Camera3D.rotation ,dados[3],0.1)
	$Camera3D.rotation = dados[3]#lerp($Camera3D.rotation ,dados[3],0.1)

func play_shoot_effectsLocal():
	#muzzeflash.emitting = true
	pass


func _on_enviar_dados_timeout() -> void:
	enviarDados()

func enviarDados():
	var dados = [multiplayer.get_unique_id(),position,rotation,$Camera3D.rotation,animation.current_animation]
	for i in range(players.size()):
		if players[i] != multiplayer.get_unique_id():
			rpc_id(players[i],"sincronizar_dados",dados)
			Start_ping(players[i])

#ping
func Start_ping(player):
	last_ping_time = Time.get_unix_time_from_system()
	rpc_id(player,"ping",false)

@rpc("any_peer")
func ping(target_id: int):  
	var sender_id: int = multiplayer.get_remote_sender_id()
	rpc_id(sender_id,"print_ping")

@rpc("any_peer")      
func print_ping():
	var pingV = Time.get_unix_time_from_system() - last_ping_time 
	Meu_ping = pingV
