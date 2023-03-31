extends Node3D


@export var should_draw_cubes := false
@export var mesh : MeshInstance3D

var aabb : AABB

var grid_step := 1
var grid_y := 0
var points := {}
var astar = AStar3D.new()

var cube_mesh = BoxMesh.new()
var red_material = StandardMaterial3D.new()
var green_material = StandardMaterial3D.new()


func _ready() -> void:
	red_material.albedo_color = Color.RED
	green_material.albedo_color = Color.GREEN
	cube_mesh.size = Vector3(0.25, 0.25, 0.25)
	aabb = AABB(mesh.position, mesh.scale)
	aabb.position =mesh.global_transform.origin #- mesh.scale /2
	_add_points()
	_connect_points()


func _add_points():
	var start_point = aabb.position - mesh.scale /2
	var x_steps = aabb.size.x / grid_step + 1
	var z_steps = aabb.size.z / grid_step + 1
	print ("size %s %s" % [x_steps, z_steps])
	for x in x_steps:
		for z in z_steps:
			var next_point = start_point + Vector3(x * grid_step, 0, z * grid_step)
			var next_point_up = next_point + Vector3.UP * 10
			_add_point(next_point)
			
func _add_point(point: Vector3):
	point.y = grid_y
	var id = astar.get_available_point_id()

	astar.add_point(id, point)
	var point_id = world_to_astar(point)
	points[point_id] = id
	
	print ("Adding point %s with point_id %s" % [point, point_id])
	_create_nav_cube(point)


func _connect_points():
	for point in points:
		var pos_str = point.split(",")
		var world_pos := Vector3(int(pos_str[0]), int(pos_str[1]), int(pos_str[2]))
		var adjacent_points = _get_adjacent_points(world_pos)
		var current_id = points[point]
		for neighbor_id in adjacent_points:
			if not astar.are_points_connected(current_id, neighbor_id):
				astar.connect_points(current_id, neighbor_id)
				if should_draw_cubes:
					get_child(current_id).material_override = green_material
					get_child(neighbor_id).material_override = green_material


func _create_nav_cube(position: Vector3):
	if should_draw_cubes:
		var cube = MeshInstance3D.new()
		cube.mesh = cube_mesh
		cube.material_override = red_material
		add_child(cube)
		position.y = grid_y
		cube.global_transform.origin = position


func _get_adjacent_points(world_point: Vector3) -> Array:
	var adjacent_points = []
	var search_coords = [-grid_step, 0, grid_step]
	for x in search_coords:
		for z in search_coords:
			var search_offset = Vector3(x, 0, z)
			if search_offset == Vector3.ZERO:
				continue

			var potential_neighbor = world_to_astar(world_point + search_offset)
			if points.has(potential_neighbor):
				adjacent_points.append(points[potential_neighbor])
	return adjacent_points


func handle_obstacle_added(obstacle: Node3D):
	print("Handling obstacle added")
	var normalized_origin = obstacle.global_transform.origin
	normalized_origin.y = grid_y

# Uncomment this line if you want to disable/enabled adjacent points
# of an obstacle.
	var adjacent_points: Array = _get_adjacent_points(normalized_origin)
#	var adjacent_points: Array = []
	var point_key = world_to_astar(normalized_origin)
	print ("point key: ", point_key)

	var astar_id = points[point_key]
	
	adjacent_points.append(astar_id)

	for point in adjacent_points:
		if not astar.is_point_disabled(point):
			astar.set_point_disabled(point, true)
			if should_draw_cubes:
				get_child(point).material_override = red_material


func handle_obstacle_removed(obstacle: Node3D):
	var normalized_origin = obstacle.global_transform.origin
	normalized_origin.y = grid_y

# Uncomment this line if you want to disable/enabled adjacent points
# of an obstacle.
	var adjacent_points: Array = _get_adjacent_points(normalized_origin)
#	var adjacent_points: Array = []
	var point_key = world_to_astar(normalized_origin)
	var astar_id = points[point_key]
	
	adjacent_points.append(astar_id)

	for point in adjacent_points:
		if astar.is_point_disabled(point):
			astar.set_point_disabled(point, false)
			if should_draw_cubes:
				get_child(point).material_override = green_material


func find_path(from: Vector3, to: Vector3) -> Array:
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	return astar.get_point_path(start_id, end_id)


func world_to_astar(world: Vector3) -> String:
	var x = snapped(world.x, grid_step)
	var y = grid_y
	var z = snapped(world.z, grid_step)
	return "%d,%d,%d" % [x, y, z]

