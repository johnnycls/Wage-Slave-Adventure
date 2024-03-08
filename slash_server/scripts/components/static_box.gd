extends StaticBody3D

func init(_pos, _scale):
	$CollisionShape3D.position = _pos
	$CollisionShape3D.scale = _scale
