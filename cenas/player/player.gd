extends CharacterBody3D

@onready var camera = $Camera3D
@onready var animation = $AnimationPlayer
@onready var muzzeflash = $Camera3D/Armas/pistola/GPUParticles3D
@onready var raycast = $Camera3D/RayCast3D

var vida = 3

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	
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
		rpc("play_shoot_effects")
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
	
	$Camera3D/ProgressBar.value = vida
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
		animation.play("Andando_Pist_1")
	else:
		animation.play("Idle_Pist_1")
	
	move_and_slide()
	var dados = [position,rotation,$Camera3D.rotation,animation.current_animation]
	rpc_id(1,"sincronizarDados",dados)

@rpc("any_peer")
func sincronizarDados(dados):
	pass

func play_shoot_effectsLocal():
	animation.stop()
	muzzeflash.restart()
	animation.play("Tiro_Pist_1")
	muzzeflash.emitting = true

@rpc("any_peer","reliable")
func recebe_Dano():
	vida -= 1
	if vida <= 0:
		global_position = Vector3.ZERO
		vida = 3
		

@rpc("any_peer","reliable")
func play_shoot_effects():
	animation.stop()
	muzzeflash.restart()
	animation.play("Tiro_Pist_1")
	muzzeflash.emitting = true
