--------------------------------------------------------------------------------

float GeneratedSDF(vec3 Test)
{
	return Union(
		Minus(
		Minus(
		Minus(
		BoxSDF(vec3(200, 200, 200), RotateY(0.7853981633974483, RotateX(-0.5235987755982988, Test))), 
		BoxSDF(vec3(150, 150, 400), RotateY(0.7853981633974483, RotateX(-0.5235987755982988, Test)))), 
		BoxSDF(vec3(150, 400, 150), RotateY(0.7853981633974483, RotateX(-0.5235987755982988, Test)))), 
		BoxSDF(vec3(400, 150, 150), RotateY(0.7853981633974483, RotateX(-0.5235987755982988, Test)))), 
		SphereSDF(100, Test));
}
