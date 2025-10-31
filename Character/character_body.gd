extends CharacterBody3D

@export var jump_speed := 4.15
@export var wall_jump_speed := 4.43
@export var wall_jump_boost := 1.17
@export var walk_speed := 6.0
@export var sprint_speed := 8.0
@export var walk_to_sprint := 0.05
@export var sprint_to_walk := 0.1
@export var ground_accel := 10.0
@export var ground_friction := 6.0
@export var stop_speed := 2.19
@export var air_accel := 2.5

const MAX_STEP_HEIGHT := 0.45

var look_sensitivity := 0.0
var wish_dir := Vector3.ZERO
var wish_speed := 0.0
var sprint_duration := 0.0
var current_sprint_speed := 0.0
var jump_queue := false
var last_wall_normal := Vector3.ZERO
var last_wall_y := -INF
var snapped_to_stairs_last := false
var last_frame_on_floor := -INF
var saved_global_camera = null

signal audio_is_jumping(active)
signal audio_is_wall_jumping(active)
signal audio_is_sprinting(speed)

func input_buffer(pressed, released, queue) -> bool:
	if released:
		return false
	return pressed or queue

func get_move_speed(delta) -> float:
	if Input.is_action_pressed("sprint"):
		sprint_duration += delta / walk_to_sprint
	else:
		sprint_duration -= delta / sprint_to_walk
	
	sprint_duration = clamp(sprint_duration, 0.0, 1.0)
	var move_speed = lerp(walk_speed, sprint_speed, sprint_duration)
	#audiohook for sprint
	audio_is_sprinting.emit(move_speed)
	return move_speed

func save_camera_pos():
	if saved_global_camera == null:
		saved_global_camera = %CameraSmooth.global_position

func camera_reset(delta):
	if saved_global_camera == null: return
	%CameraSmooth.global_position.y = saved_global_camera.y
	%CameraSmooth.position.y = clamp(%CameraSmooth.position.y, -0.7, 0.7)
	var move_amount = max(self.velocity.length() * delta, get_move_speed(delta) / 2 * delta)
	%CameraSmooth.position.y = move_toward(%CameraSmooth.position.y, 0.0, move_amount)
	saved_global_camera = %CameraSmooth.global_position
	if %CameraSmooth.position.y == 0:
		saved_global_camera = null

func _ready():
	look_sensitivity = TAU / (Global.cm_per_360 * Global.dpi / 2.54)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func clip_velocity(normal, overbounce) -> void:
	var backoff = self.velocity.dot(normal) * overbounce
	if backoff >= 0: return
	var change = normal * backoff
	self.velocity -= change
	
	var adjust = self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust

func is_surface_too_steep(normal) -> bool:
	var max_slope_ang_dot = Vector3(0, 1, 0).rotated(Vector3(1, 0, 0), self.floor_max_angle).dot(Vector3(0 ,1, 0))
	if normal.dot(Vector3(0, 1, 0)) < max_slope_ang_dot:
		return true
	return false
	
func run_body_test_motion(from, motion, result = null) -> bool:
	if not result: result = PhysicsTestMotionParameters3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)
	
func stair_check(delta) -> bool:
	if not is_on_floor() and not snapped_to_stairs_last: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairFrontRayCast.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		%StairFrontRayCast.force_raycast_update()
		if %StairFrontRayCast.is_colliding() and not is_surface_too_steep(%StairFrontRayCast.get_collision_normal()):
			save_camera_pos()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			snapped_to_stairs_last = true
			return true
	return false

func wall_bounce() -> void:
	if not jump_queue or not is_on_wall_only():
		return
	
	var wall_normal = get_wall_normal()
	
	# ignore surf ramps
	if abs(wall_normal.y) > 0.08:
		return

	# only allow bounce if hitting a different wall or below previous bounce height
	if wall_normal == last_wall_normal and global_transform.origin.y >= last_wall_y:
		return

	velocity = (wall_normal * current_sprint_speed * 0.5) + (velocity * wall_jump_boost)
	velocity.y = wall_jump_speed
	
	#audiohook for wall jump
	audio_is_wall_jumping.emit(true)
	await get_tree().process_frame
	audio_is_wall_jumping.emit(false)
	
	jump_queue = false

	last_wall_normal = wall_normal
	last_wall_y = global_transform.origin.y


func _handle_air_physics(delta) -> void:
	var wish_velocity = wish_dir * wish_speed
	
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0.0
	
	# zweeks suggestion of what new doom style movement may be
	# scale wish speed up to target speed if below
	if horizontal_velocity.length() > wish_speed:
		var wish_norm = wish_dir.normalized()
		var projected_speed = horizontal_velocity.dot(wish_norm)
		# angle based speed loss
		if projected_speed > 0.0:
			wish_velocity = wish_dir.normalized() * max(projected_speed, wish_speed)
		else:
			wish_velocity = wish_dir * wish_speed
	
	var push_dir = wish_velocity - velocity
	push_dir.y = 0.0
	var push_len = push_dir.length()
	
	if push_len > 0.0:
		push_dir = push_dir.normalized()
		var can_push = air_accel * delta * wish_speed
		if can_push > push_len:
			can_push = push_len
		velocity += push_dir * can_push
	
	# apply gravity
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# surf physics
	if is_on_wall():
		# if steep then use air physics so you slide down
		if is_surface_too_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1)
	
	# wall bounce
	wall_bounce()

func apply_friction(delta) -> void:
	var speed = velocity.length()
	if speed == 0.0:
		return
	
	var drop := 0.0
	var control = stop_speed if speed < stop_speed else speed
	drop = control * ground_friction * delta
		
	var new_speed = speed - drop
	if new_speed < 0.0:
		new_speed = 0.0

	if new_speed != speed:
		self.velocity *= new_speed / speed

# q3 default ground accel
func _handle_ground_physics(delta) -> void:
	var current_speed = velocity.dot(wish_dir)
	var add_speed = current_sprint_speed - current_speed

	if add_speed < 0.0:
		var decel_speed = ground_accel * current_sprint_speed * delta
		if -add_speed < decel_speed:
			decel_speed = -add_speed
		velocity -= wish_dir * decel_speed
		apply_friction(delta)
		return

	if add_speed == 0.0:
		apply_friction(delta)
		return

	var accel_speed = ground_accel * current_sprint_speed * delta
	if add_speed < accel_speed:
		accel_speed = add_speed

	self.velocity.x += accel_speed * wish_dir.x
	self.velocity.y += accel_speed * wish_dir.y
	self.velocity.z += accel_speed * wish_dir.z
	
	apply_friction(delta)
	
	# allow wall kick after hitting ground
	last_wall_normal = Vector3.ZERO
	last_wall_y = -INF

func _physics_process(delta):
	snapped_to_stairs_last = false
	last_frame_on_floor = Engine.get_physics_frames()
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)

	# jump buffer
	jump_queue = input_buffer(Input.is_action_just_pressed("jump"), Input.is_action_just_released("jump"), jump_queue)
	current_sprint_speed = get_move_speed(delta)

	wish_speed = current_sprint_speed if input_dir != Vector2.ZERO else 0.0
	
	if is_on_floor() or snapped_to_stairs_last: # snapped to stairs last for smoothness
		if jump_queue:
			self.velocity.y = jump_speed
			#audiohook for wall jump
			audio_is_jumping.emit(true)
			await get_tree().process_frame
			audio_is_jumping.emit(false)
			jump_queue = false
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	if not stair_check(delta):
		#stair check moves character manually
		move_and_slide()
	
	camera_reset(delta)
