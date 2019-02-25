--------------------------------------------------------------------------------

float GeneratedSDF(vec3 Test)
{
	return Minus(
		Minus(
		Minus(
		Minus(
		Minus(
		SphereSDF(200, Test), 
		SphereSDF(150, Translate(vec3(-50, -50, 100), Test))), 
		SphereSDF(80, Translate(vec3(100, 100, 100), Test))), 
		SphereSDF(100, Translate(vec3(-10, -10, -100), Test))), 
		BoxSDF(vec3(60, 400, 60), RotateY(0.7853981633974483, Translate(vec3(100, 0, 55), Test)))), 
		BoxSDF(vec3(50, 50, 400), RotateZ(0.7853981633974483, Translate(vec3(-100, -100, 0), Test))));
}
