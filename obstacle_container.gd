extends Node3D


const OBSTACLE = preload("res://obstacle.tscn")

signal obstacle_added(obstacle)
signal obstacle_removed(obstacle)


func create_obstacle(location: Vector3):
	var obstacle_instance = OBSTACLE.instantiate()
	add_child(obstacle_instance)
	obstacle_instance.global_transform.origin = location
	obstacle_added.emit(obstacle_instance)


func delete_obstacle(obstacle: MeshInstance3D):
	obstacle_removed.emit(obstacle)
	obstacle.queue_free()


func handle_obstacle_should_spawn(location: Vector3):
	var snapped_location = Vector3(
		snapped(location.x, 1),
		0.5,
		snapped(location.z, 1)
	)

	for c in get_children():
		if c.global_transform.origin == snapped_location:
			delete_obstacle(c)
			return
	
	print("create obstacle to", snapped_location)
	create_obstacle(snapped_location)
