extends Node3D

@onready var mesh = $MeshInstance3D
@onready var player = $Player

signal obstacle_should_spawn(location)

func _ready():
	
	$ObstacleContainer.connect("obstacle_added",Callable($AStarManager,"handle_obstacle_added"))
	$ObstacleContainer.connect("obstacle_removed",Callable($AStarManager,"handle_obstacle_removed"))
	player.connect("got_stuck", player_got_stuck)
var _mouse_position = Vector2()

	
func get_mouse_target() -> Dictionary:
	var camera = $Camera3D
	var mousePos = get_viewport().get_mouse_position()
	var rayLength = 100
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * rayLength
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collision_mask =5
	rayQuery.collide_with_areas = true
	var result = space.intersect_ray(rayQuery)
	return result

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:

		var result = get_mouse_target()
		if result != null and not result.is_empty():
			if event.is_action_pressed("ui_select"):
				Debugger.draw_line_3d(result.position,result.position + Vector3.UP, Color.ORANGE)
			elif event.is_action_pressed("drop_obstacle"):
				$ObstacleContainer.handle_obstacle_should_spawn(result.position)
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_physical_key_pressed(KEY_X):
		
		var result = get_mouse_target()		
		if result != null and not result.is_empty():
			player.update_path($AStarManager.find_path(player.position, result.position))
	

func player_got_stuck():
	player.update_path($AStarManager.find_path(player.position, player.target_path_end))
