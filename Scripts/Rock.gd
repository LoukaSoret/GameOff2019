extends MeshInstance

# Grass Generator Parameters
export var grass_spacing : float = 0.0025
export var grass_density : int = 32

# Rock Deformation Parameter
export var deformationSeed : int = 0
export(float,0,1) var deformation

# Perlin Parameters
export(float,0,1) var perlin_scale;
export(float,0,10) var amplitude  = 2;
export(float,0,100) var frequency  = 4;
export(float,0,1) var persistence = 0.2;
export var nboctaves : int = 4;

onready var grass_material_ressource = load("res://Ressources/grass/grass_material.tres").duplicate()

func fract(n:float) -> float:
	return n-floor(n)

func fractVec3(v : Vector3) -> Vector3:
	var res : Vector3 = Vector3()
	res.x = fract(v.x)
	res.y = fract(v.y)
	res.z = fract(v.z)
	return res

func fractVec2(v : Vector2) -> Vector2:
	var res : Vector2 = Vector2()
	res.x = fract(v.x)
	res.y = fract(v.y)
	return res

func floorVec3(v:Vector3) -> Vector3:
	var res : Vector3 = Vector3()
	res.x = floor(v.x)
	res.y = floor(v.y)
	res.z = floor(v.z)
	return res

func floorVec2(v:Vector2) -> Vector2:
	var res : Vector2 = Vector2()
	res.x = floor(v.x)
	res.y = floor(v.y)
	return res

func sinVec2(v: Vector2) -> Vector2:
	var res : Vector2 = Vector2()
	res.x = sin(v.x)
	res.y = sin(v.y)
	return res

func myHash(n : float) -> float:
	return fract(sin(n)*43758.5453)

func noise(x : Vector3) -> float:
	# The noise function returns a value in the range -1.0f -> 1.0f
	var p : Vector3 = floorVec3(x)
	var f : Vector3 = fractVec3(x)
	f = f*f*(Vector3.ONE*3.0-2.0*f)
	var n : float = p.x + p.y*57.0 + 113.0*p.z
	
	return lerp(lerp(lerp(myHash(n+0.0),myHash(n+1.0),f.x),lerp(myHash(n+57.0),myHash(n+58.0),f.x),f.y),lerp(lerp( myHash(n+113.0), myHash(n+114.0),f.x),lerp( myHash(n+170.0), myHash(n+171.0),f.x),f.y),f.z)

# Prelin Noise functions
func perlinhash(p : Vector2) -> Vector2:
	p = Vector2(p.dot(Vector2(127.1,311.7)), p.dot(Vector2(269.5,183.3)));
	return -1.0*Vector2.ONE + 2.0*fractVec2(sinVec2(p)*43758.5453123);

func gnoise(p : Vector2) -> float:
	var i : Vector2 = floorVec2(p);
	var f : Vector2 = fractVec2(p);
	var u : Vector2 = f*f*(Vector2.ONE*3.0-2.0*f);
	return lerp( lerp(perlinhash( i + Vector2(0.0,0.0) ).dot(f - Vector2(0.0,0.0) ),
				 perlinhash( i + Vector2(1.0,0.0) ).dot(f - Vector2(1.0,0.0)), u.x),
				lerp( perlinhash( i + Vector2(0.0,1.0) ).dot(f - Vector2(0.0,1.0) ),
				 perlinhash( i + Vector2(1.0,1.0) ).dot( f - Vector2(1.0,1.0) ), u.x), u.y);

func pnoise(p:Vector2,amp : float,freq : float,pers : float, nboct : float) -> float:
	var a : float = amp;
	var f : float = freq;
	var n : float = 0.0;
	for i in range(0,nboct):
		n = n+a*gnoise(p*f);
		f = f*2.0;
		a = a*pers;
	return n;

func displace():
	var mdt = MeshDataTool.new()
	var new_mesh : Mesh = mesh.duplicate()
	var vertex
	var displacement : float
	mdt.create_from_surface(new_mesh, 0)
	for i in range(mdt.get_vertex_count()):
		vertex = mdt.get_vertex(i)
		displacement = (noise(vertex+Vector3.ONE*float(deformationSeed)) * 2.0 - 1.0)*deformation
		if(mdt.get_vertex_normal(i).angle_to(Vector3.DOWN) < deg2rad(90) ):
			vertex.y += pnoise(Vector2(vertex.x,vertex.y)+Vector2.ONE*float(deformationSeed),amplitude,frequency,persistence, nboctaves)*perlin_scale
		vertex += Vector3.ONE*displacement
		mdt.set_vertex(i, vertex)
    # Calculate vertex normals, face-by-face.
	for i in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		# Calculate face normal.
		var n = (bp - cp).cross(ap - bp).normalized()
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
	
	# Run through vertices one last time to normalize normals
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
	new_mesh.surface_remove(0)
	mdt.commit_to_surface(new_mesh)
	mesh = new_mesh

func generate_grass_mesh():
	var mdt = MeshDataTool.new()
	var st = SurfaceTool.new()
	var new_mesh : ArrayMesh = ArrayMesh.new()
	new_mesh.resource_local_to_scene = true
	var vertex
	mdt.create_from_surface(mesh, 0)
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(grass_density):
		for i in range(mdt.get_face_count()):
			if(mdt.get_face_normal(i).angle_to(Vector3.UP) < deg2rad(45)):
				# Get vertex position using vertex index.
				var ap = mdt.get_vertex(mdt.get_face_vertex(i,0))
				var bp = mdt.get_vertex(mdt.get_face_vertex(i,1))
				var cp = mdt.get_vertex(mdt.get_face_vertex(i,2))
				
				st.add_normal(mdt.get_vertex_normal(mdt.get_face_vertex(i,0)))
				st.add_uv(mdt.get_vertex_uv(mdt.get_face_vertex(i,0)))
				st.add_color(Color(1-(1.0/grass_density)*j,1-(1.0/grass_density)*j,1-(1.0/grass_density)*j))
				st.add_vertex(ap-Vector3(0,grass_spacing,0)*j)
				st.add_normal(mdt.get_vertex_normal(mdt.get_face_vertex(i,1)))
				st.add_uv(mdt.get_vertex_uv(mdt.get_face_vertex(i,1)))
				st.add_color(Color(1-(1.0/grass_density)*j,1-(1.0/grass_density)*j,1-(1.0/grass_density)*j))
				st.add_vertex(bp-Vector3(0,grass_spacing,0)*j)
				st.add_normal(mdt.get_vertex_normal(mdt.get_face_vertex(i,2)))
				st.add_uv(mdt.get_vertex_uv(mdt.get_face_vertex(i,2)))
				st.add_color(Color(1-(1.0/grass_density)*j,1-(1.0/grass_density)*j,1-(1.0/grass_density)*j))
				st.add_vertex(cp-Vector3(0,grass_spacing,0)*j)

	st.commit(new_mesh)
	var mesh_instance : MeshInstance = MeshInstance.new()
	var material = grass_material_ressource
	var noise_scale = material.get("shader_param/_NoiseScale")
	material.set("shader_param/_NoiseScale",noise_scale*scale)
	material.set("shader_param/_NoiseScale",noise_scale*scale)
	mesh_instance.mesh = new_mesh
	mesh_instance.transform.origin.y = grass_spacing*grass_density
	mesh_instance.set_surface_material(0,material)
	add_child(mesh_instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	displace()
	create_trimesh_collision()
	generate_grass_mesh()