extends CharacterBody3D

var path := []
var current_target := Vector3.INF
var current_velocity := Vector3.ZERO
@export var target_path_end : Vector3 = Vector3.INF
var speed := 5.0

enum State {
	Idle,
	Moving,
	Stuck
}

var state := State.Idle
signal arrived
signal got_stuck

const time_to_wait_when_stuck_in_ms = 50
var stuck_started = 0

func _physics_process(delta: float) -> void:
	
	match state:
		State.Idle:
			print ("Idle")
			pass
		State.Moving:
			print ("Moving")
			_update_moving(delta)
		State.Stuck:
			print ("STuck")
			_update_stuck(delta)

func _update_moving(delta: float) -> void:
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			state = State.Idle
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
		
	set_velocity(new_velocity)
	
	
	
	current_velocity = velocity
	
	var hit = move_and_slide()
	if (hit):
		print ("hit but moving ",velocity)
		if _is_stuck():
			state = State.Stuck
	
func _is_stuck() -> bool:
	print ("velocity ",velocity.round())
	print ("velocityfloor() ",velocity.round().floor())
	if (velocity.round().floor() == Vector3.ZERO) and path.size() > 0:
		if stuck_started == 0:
			print ("start stuck counter")
			stuck_started = Time.get_ticks_msec()
			
		if Time.get_ticks_msec() - stuck_started > time_to_wait_when_stuck_in_ms:
			print("not moving but still ways to go ",path.size())
			stuck_started = 0
			return true
	return false
	
func _update_stuck(delta: float) -> void:
	state = State.Idle
	got_stuck.emit()

func find_next_point_in_path() -> void:
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
		state = State.Moving
	else:
		arrived.emit()
		current_target = Vector3.INF

func update_path(new_path: Array) -> void:
	if new_path == []:
		return
	path = new_path
	target_path_end = new_path[new_path.size() - 1]
	find_next_point_in_path()
