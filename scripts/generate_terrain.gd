@tool
extends EditorScript

@export var island_size: Vector2i = Vector2i(256, 256)
@export var height_scale: float = 12.0
@export var noise_scale: float = 0.015
@export var octaves: int = 5
@export var persistence: float = 0.55
@export var lacunarity: float = 2.0
@export var beach_height: float = 0.35
@export var water_level: float = -0.5
@export var cliff_threshold: float = 0.7
@export var seed: int = 42

func _run() -> void:
	var heightmap = _generate_heightmap()
	var mesh = _create_terrain_mesh(heightmap)
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVES_TRIANGLES, mesh)
	
	var save_path = "res://assets/meshes/island_terrain.tres"
	ResourceSaver.save(array_mesh, save_path)
	print("Saved terrain mesh to: ", save_path)
	
	var collision_mesh = _create_collision_mesh(heightmap)
	var collision_array_mesh = ArrayMesh.new()
	collision_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVES_TRIANGLES, collision_mesh)
	
	var collision_save_path = "res://assets/meshes/island_collision.tres"
	ResourceSaver.save(collision_array_mesh, collision_save_path)
	print("Saved collision mesh to: ", collision_save_path)

func _generate_heightmap() -> Array:
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = octaves
	noise.fractal_persistence = persistence
	noise.fractal_lacunarity = lacunarity
	
	var size = island_size
	var heightmap = []
	heightmap.resize(size.x * size.y)
	
	var center = Vector2(size.x * 0.5, size.y * 0.5)
	var max_radius = min(size.x, size.y) * 0.48
	
	for y in range(size.y):
		for x in range(size.x):
			var idx = y * size.x + x
			var pos = Vector2(x, y)
			var dist_from_center = pos.distance_to(center) / max_radius
			
			var n = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			n = (n + 1.0) * 0.5
			
			var island_shape = 1.0 - smoothstep(0.3, 1.0, dist_from_center)
			island_shape = pow(island_shape, 1.5)
			
			var height = n * island_shape
			
			if dist_from_center < 0.25:
				height = max(height, 0.4 + n * 0.3)
			
			heightmap[idx] = height
	
	return heightmap

func _create_terrain_mesh(heightmap: Array) -> Array:
	var size = island_size
	var vertices = []
	var uvs = []
	var normals = []
	var indices = []
	
	var vertex_map = {}
	
	for y in range(size.y):
		for x in range(size.x):
			var idx = y * size.x + x
			var height = heightmap[idx] * height_scale
			
			var world_x = (x - size.x * 0.5) * 1.0
			var world_z = (y - size.y * 0.5) * 1.0
			
			vertices.append(Vector3(world_x, height, world_z))
			uvs.append(Vector2(x / float(size.x), y / float(size.y)))
	
	for y in range(size.y - 1):
		for x in range(size.x - 1):
			var a = y * size.x + x
			var b = y * size.x + x + 1
			var c = (y + 1) * size.x + x
			var d = (y + 1) * size.x + x + 1
			
			indices.append(a)
			indices.append(c)
			indices.append(b)
			
			indices.append(b)
			indices.append(c)
			indices.append(d)
	
	for i in range(vertices.size()):
		normals.append(Vector3(0, 1, 0))
	
	for y in range(size.y):
		for x in range(size.x):
			var idx = y * size.x + x
			var normal = Vector3(0, 0, 0)
			var count = 0
			
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					var nx = x + dx
					var ny = y + dy
					if nx >= 0 and nx < size.x and ny >= 0 and ny < size.y:
						var n_idx = ny * size.x + nx
						var h_current = heightmap[idx] * height_scale
						var h_neighbor = heightmap[n_idx] * height_scale
						var diff = h_neighbor - h_current
						if dx != 0:
							normal.x += diff * dx
						if dy != 0:
							normal.z += diff * dy
						count += 1
			
			if count > 0:
				normal = normal.normalized()
				normals[idx] = normal
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	return arrays

func _create_collision_mesh(heightmap: Array) -> Array:
	var size = island_size
	var step = 4
	var vertices = []
	var indices = []
	
	for y in range(0, size.y, step):
		for x in range(0, size.x, step):
			var idx = y * size.x + x
			var height = heightmap[idx] * height_scale
			
			var world_x = (x - size.x * 0.5) * 1.0
			var world_z = (y - size.y * 0.5) * 1.0
			
			vertices.append(Vector3(world_x, height, world_z))
	
	var grid_w = (size.x + step - 1) / step
	var grid_h = (size.y + step - 1) / step
	
	for gy in range(grid_h - 1):
		for gx in range(grid_w - 1):
			var a = gy * grid_w + gx
			var b = gy * grid_w + gx + 1
			var c = (gy + 1) * grid_w + gx
			var d = (gy + 1) * grid_w + gx + 1
			
			if a < vertices.size() and b < vertices.size() and c < vertices.size() and d < vertices.size():
				indices.append(a)
				indices.append(c)
				indices.append(b)
				
				indices.append(b)
				indices.append(c)
				indices.append(d)
	
	var normals = []
	for i in range(vertices.size()):
		normals.append(Vector3(0, 1, 0))
	
	var uvs = []
	for i in range(vertices.size()):
		uvs.append(Vector2(0, 0))
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	return arrays