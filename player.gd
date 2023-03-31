extends CharacterBody3D


var path := []
var current_target := Vector3.INF
var current_velocity := Vector3.ZERO
@export var target_path_end : Vector3 = Vector3.INF
var speed := 5.0


signal got_stuck
signal arrived
var stuck_started = 0
const time_to_wait_when_stuck_in_ms = 50

func _physics_process(delta: float) -> void:
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
		
	set_velocity(new_velocity)
	
	move_and_slide()

	_check_if_stuck()
	
	current_velocity = velocity


func _check_if_stuck()->void:
	if (current_velocity.floor() == Vector3.ZERO) and path.size() > 0:
		if (stuck_started == 0):
			stuck_started = Time.get_ticks_msec()
			
		if (Time.get_ticks_msec() - stuck_started > time_to_wait_when_stuck_in_ms):
			print("not moving but still ways to go ",path.size())
			got_stuck.emit()
	else:
		stuck_started = 0
		
func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
	else:
		arrived.emit()
		current_target = Vector3.INF


func update_path(new_path: Array):
	if (new_path == []):
		return
	path = new_path
	target_path_end = new_path[new_path.size()-1]
	find_next_point_in_path()

