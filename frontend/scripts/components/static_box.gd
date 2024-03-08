extends StaticBody3D

func init(p, s, c="FFFFFF"):
	$CollisionShape3D.position = p
	$CollisionShape3D.scale = s
	$MeshInstance3D.position = p
	$MeshInstance3D.scale = s
	$MeshInstance3D.get_active_material(0).albedo_color = Color(c)
