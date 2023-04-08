class_name AStarExperiment

# Inheritance:
extends Node3D

# Set this to true if you want to draw cubes to visualize the navmesh and obstacles
@export var should_draw_cubes := false

# The mesh used to create the navmesh
@export var mesh : MeshInstance3D

# Set this to true if you want to disable adjacent points of an obstacle
@export var enable_adjacent_points := false

# The axis-aligned bounding box (AABB) of the navmesh
var aabb : AABB

# The distance between each point in the navmesh grid
var grid_step := 1

# The Y coordinate of the navmesh grid
var grid_y := 0

# A dictionary mapping point coordinates to AStar3D point IDs
var points := {}

# An instance of the AStar3D class used to navigate the navmesh
var astar = AStar3D.new()

# A mesh used to draw cubes for the navmesh and obstacles
var cube_mesh = BoxMesh.new()

# A material used to draw red cubes for obstacles
var red_material = StandardMaterial3D.new()

# A material used to draw green cubes for the navmesh
var green_material = StandardMaterial3D.new()


func _ready() -> void:
	# Get the AABB of the navmesh mesh
	aabb = AABB(mesh.position, mesh.scale)
	
	# Set the position of the AABB to the global position of the navmesh mesh
	aabb.position = mesh.global_transform.origin
	
	# Add points to the navmesh grid
	_add_points()
	
	# Connect adjacent points in the navmesh grid
	_connect_points()

func _init() -> void:
	red_material.albedo_color = Color.RED
	
	# Set the color of the green material to green
	green_material.albedo_color = Color.GREEN
	
	# Set the size of the cube mesh to (0.25, 0.25, 0.25)
	cube_mesh.size = Vector3(0.25, 0.25, 0.25)

	
func _add_points():
	# Calculate the starting point of the navmesh grid
	var start_point = aabb.position - mesh.scale / 2
	
	# Calculate the number of steps in the X and Z directions of the navmesh grid
	var x_steps = aabb.size.x / grid_step + 1
	var z_steps = aabb.size.z / grid_step + 1
	
	# Add a point for each grid cell in the navmesh
	for x in x_steps:
		for z in z_steps:
			var next_point = start_point + Vector3(x * grid_step, 0, z * grid_step)
			var next_point_up = next_point + Vector3.UP * 10
			_add_point(next_point)
	

func _add_point(point: Vector3):
	# Set the Y coordinate of the point to the Y coordinate of the navmesh grid
	point.y = grid_y
	
	# Get an available point ID from the AStar3D instance
	var id = astar.get_available_point_id()
	
	# Add the point to the AStar3D instance
	astar.add_point(id, point)
	
	# Get a string key for the point based on its coordinates
	var point_key = _world_to_astar(point)
	
	# Add the point ID to the dictionary of points
	points[point_key] = id
	
	# Draw a red cube for the point if should_draw_cubes is true
	_create_nav_cube(point)
# Connect all adjacent points to each other in the navigation mesh
func _connect_points():
	# Loop through all points in the navigation mesh
	for point in points:
		# Split the point string into its x, y, and z coordinates
		var pos_str = point.split(",")
		# Create a new Vector3 with the integer values of the x, y, and z coordinates
		var world_pos := Vector3(int(pos_str[0]), int(pos_str[1]), int(pos_str[2]))
		# Get an array of all adjacent points to the current point
		var adjacent_points = _get_adjacent_points(world_pos)
		# Get the ID of the current point
		var current_id = points[point]
		# Loop through all adjacent points
		for neighbor_id in adjacent_points:
			# If the current point and the adjacent point are not already connected, connect them
			if not astar.are_points_connected(current_id, neighbor_id):
				astar.connect_points(current_id, neighbor_id)
				# If the should_draw_cubes flag is true, change the material of the cubes at the current and adjacent points to green
				if should_draw_cubes:
					get_child(current_id).material_override = green_material
					get_child(neighbor_id).material_override = green_material


# Create a new navigation cube at the given position
func _create_nav_cube(position: Vector3):
	if should_draw_cubes:
		# Create a new MeshInstance3D node and set its mesh and material
		var cube = MeshInstance3D.new()
		cube.mesh = cube_mesh
		cube.material_override = red_material
		# Set the position of the cube and add it as a child to this node
		position.y = grid_y
		cube.global_transform.origin = position
		add_child(cube)


# Get an array of all adjacent points to the given point in the navigation mesh
func _get_adjacent_points(world_point: Vector3) -> Array:
	# Create an empty array to store the adjacent points
	var adjacent_points = []
	# Create an array of search offsets for each direction
	var search_coords = [-grid_step, 0, grid_step]
	# Loop through all search offsets
	for x in search_coords:
		for z in search_coords:
			# Skip the offset of (0, 0, 0) as that is the current point
			var search_offset = Vector3(x, 0, z)
			if search_offset == Vector3.ZERO:
				continue
			# Convert the world point plus the search offset to an AStar point string
			var potential_neighbor = _world_to_astar(world_point + search_offset)
			# If the AStar point string is in the points dictionary, append its ID to the adjacent_points array
			if points.has(potential_neighbor):
				adjacent_points.append(points[potential_neighbor])
	# Return the array of adjacent point IDs
	return adjacent_points


# Handle an obstacle being added to the scene
func handle_obstacle_added(obstacle: Node3D) -> Vector3:
	# Log the obstacle event
	print("Handling obstacle added")
	
	# Normalize the obstacle's position to the grid
	var normalized_origin = obstacle.global_transform.origin
	normalized_origin.y = grid_y
	
	# Get an array of adjacent point IDs to the obstacle's normalized position
	var adjacent_points :Array
	if enable_adjacent_points:
		adjacent_points = _get_adjacent_points(normalized_origin)
	else:
		adjacent_points = []
	
	# Get the AStar point ID for the obstacle's normalized position
	var point_key = _world_to_astar(normalized_origin)
	print("point key: ", point_key)

	var astar_id = points[point_key]
	
	# Add the obstacle's point ID to the adjacent points array
	adjacent_points.append(astar_id)

	# Disable each adjacent point to the obstacle
	for point in adjacent_points:
		if not astar.is_point_disabled(point):
			astar.set_point_disabled(point, true)
			# Optionally change the color of the point's cube to red
			if should_draw_cubes:
				get_child(point).material_override = red_material
				
	print("obstacle added")
	
	point_key.split(",")
		# Create a new Vector3 with the integer values of the x, y, and z coordinates
	var pos := Vector3(int(point_key[0]), int(point_key[1]), int(point_key[2]))
	return pos
	
# Given a start and end point in 3D space, find a path between them using A* algorithm
# Params:
# - from: The starting point (Vector3)
# - to: The ending point (Vector3)
# Returns:
# - Array of points representing the path, where each point is a Vector3 in 3D space
func find_path(from: Vector3, to: Vector3) -> Array:
	# Find the closest AStar point ID to the starting and ending points
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	
	# Get the AStar path between the start and end points
	return astar.get_point_path(start_id, end_id)



func _world_to_astar(world: Vector3) -> String:
	# Snap the world position to the nearest grid point
	var x = snapped(world.x, grid_step)
	var y = grid_y
	var z = snapped(world.z, grid_step)
	
	# Return the AStar point string for the snapped position
	return "%d,%d,%d" % [x, y, z]

