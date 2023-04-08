extends Node3D
const OBSTACLE = preload("res://obstacle.tscn")

func _ready():
	test_map_creation()
	test_find_path()
	test_handle_obstacle()
	test_find_path_with_obstacle()
	
func test_map_creation():
	# Create an instance of the AStarExperiment class
	var astar_experiment = AStarExperiment.new()
	# Set the should_draw_cubes flag to false to avoid drawing cubes
	astar_experiment.should_draw_cubes = false
	# Set the mesh property to a MeshInstance3D with a simple navmesh
	
	astar_experiment.mesh = _create_navmesh_mesh()
	astar_experiment._ready()
	
	var points = astar_experiment.astar.get_point_count()
	assert(points == 121)
	
	
func test_find_path():
	# Create an instance of the AStarExperiment class
	var astar_experiment = AStarExperiment.new()
	# Set the should_draw_cubes flag to false to avoid drawing cubes
	astar_experiment.should_draw_cubes = false
	# Set the mesh property to a MeshInstance3D with a simple navmesh
	
	astar_experiment.mesh = _create_navmesh_mesh()
	astar_experiment._ready()
	# Set the start and goal positions for the pathfinding
	var start_pos = Vector3(0, 0, 0)
	var goal_pos = Vector3(0, 0, 4)
	# Call the find_path method to get the path between the start and goal positions
	var path = astar_experiment.find_path(start_pos, goal_pos)
	# Assert that the path is not empty and that it has the correct length
	assert(path.size() > 0)
	assert(path.size() == 5)

func test_handle_obstacle():
	# Create an instance of the AStarExperiment class
	var astar_experiment = AStarExperiment.new()
	# Set the should_draw_cubes flag to false to avoid drawing cubes
	astar_experiment.should_draw_cubes = false
	
	astar_experiment.mesh = _create_navmesh_mesh()
	astar_experiment._ready()
	# Set the obstacle position and size
	# Call the handle_obstacle_added method to add the obstacle to the navmesh
	var obstacle = _create_obstacle(Vector3(2, 0, 2))
	
	astar_experiment.handle_obstacle_added(obstacle)
	# Assert that the obstacle was added to the navmesh
	var pc = astar_experiment.astar.get_point_count()
	assert(astar_experiment.astar.get_point_count() == 121)
	
func test_find_path_with_obstacle():
	# Create an instance of the AStarExperiment class
	var astar_experiment = AStarExperiment.new()
	# Set the should_draw_cubes flag to false to avoid drawing cubes
	astar_experiment.should_draw_cubes = false
	# Set the mesh property to a MeshInstance3D with a simple navmesh
	
	astar_experiment.mesh = _create_navmesh_mesh()
	astar_experiment._ready()
	# Set the start and goal positions for the pathfinding
	var start_pos = Vector3(0, 0, 0)
	var goal_pos = Vector3(0, 0, 4)
	
	var obstacle = _create_obstacle(goal_pos)
	var o = astar_experiment.handle_obstacle_added(obstacle)
	# Call the find_path method to get the path between the start and goal positions
	
	# Call the find_path method to get the path between the start and goal positions
	var path = astar_experiment.find_path(start_pos, goal_pos)
	# Assert that the path is not empty and that it has the correct length
	assert(path.size() > 0)
	assert(path.size() == 5)
	
	
func _create_obstacle(obstacle_pos) -> MeshInstance3D:
	var obs = OBSTACLE.instantiate()
	obs.global_transform.origin = obstacle_pos
	return obs
	
func _create_navmesh_mesh() -> MeshInstance3D:
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.scale = Vector3(10, 1, 10)
	return mesh
#
#func test_navigation() -> void:
## Create a new Navigation node
#
#	# Set up the navmesh and obstacles
#
#	nav.mesh = MeshInstance3D.new()
#	nav.mesh.mesh = BoxMesh.new()
#	nav.mesh.scale = Vector3(10, 1, 10)
#	nav.should_draw_cubes = true
#	nav.enable_adjacent_points = true
#	nav._ready()
#
#	# Test that the AStar3D class is set up correctly
#	assert(nav.astar is AStar3D)
#
#	# Test that the correct number of points have been added to the navmesh grid
#	assert(nav.points.size() == 121)
#
#	# Test that adjacent points are disabled if the enable_adjacent_points flag is set to false
#	nav.enable_adjacent_points = false
#	nav._connect_points()
#	for point in nav.points:
#		var node = nav.get_child(nav.points[point])
#		var adjacent_nodes = node.get_children()
#		assert(adjacent_nodes.size() == 0)
#
#	# Test that the navmesh grid is drawn correctly
#	for point in nav.points:
#		var node = nav.get_child(nav.points[point])
#		if point == "5,0,5":
#			# Test that the center point is green
#			assert(node.material_override.albedo_color == Color.GREEN)
##		else:
##			# Test that all other points are red
##			assert(node.material_override.albedo_color == Color.RED)
#
#	# Test that pathfinding works correctly
#	var path = nav.astar.get_point_path(Vector3(0, 0, 0), Vector3(10, 0, 10))
#	assert(path.size() == 11)
#	assert(path[0] == nav.points["0,0,0"])
#	assert(path[10] == nav.points["10,0,10"])
#
#	# Test that pathfinding fails when there is an obstacle in the way
#	var obstacle = MeshInstance3D.new()
#	obstacle.mesh = BoxMesh.new()
#	obstacle.scale = Vector3(3, 3, 3)
#	obstacle.translation = Vector3(5, 0, 5)
#	obstacle.name = "obstacle"
#	nav.add_child(obstacle)
#	nav._add_points()
#	nav._connect_points()
#	path = nav.astar.get_point_path(Vector3(0, 0, 0), Vector3(10, 0, 10))
#	assert(path.size() == 0)
#
#	# Test that pathfinding works correctly when adjacent points are disabled
#	nav.enable_adjacent_points = true
#	nav._connect_points()
#	path = nav.astar.get_point_path(Vector3(0, 0, 0), Vector3(10, 0, 10))
#	assert(path.size() == 11)
#	assert(path[0] == nav.points["0,0,0"])
#	assert(path[10] == nav.points["10,0,10"])
#
#	# Remove the nav node from the scene
#	nav.queue_free()
