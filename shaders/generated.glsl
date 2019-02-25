--------------------------------------------------------------------------------

float GeneratedSDF(vec3 Test)
{
	return Union(
		Union(
		Union(
		Union(
		Union(
		Minus(
		Minus(
		Minus(
		Minus(
		Minus(
		SphereSDF(200, Test), 
		SphereSDF(150, Translate(vec3(-50, -50, 100), Test))), 
		SphereSDF(80, Translate(vec3(100, 100, 100), Test))), 
		SphereSDF(100, Translate(vec3(-10, -10, -100), Test))), 
		BoxSDF(vec3(60, 400, 60), RotateY(0.7853981633974483, Translate(vec3(100, 0, 55), Test)))), 
		BoxSDF(vec3(50, 50, 400), RotateZ(0.7853981633974483, Translate(vec3(-100, -100, 0), Test)))), 
		Minus(
		Minus(
		Minus(
		Inter(
		SphereSDF(50, Translate(vec3(310, 125, 0), Test)), 
		SphereSDF(50, Translate(vec3(290, 125, 0), Test))), 
		SphereSDF(35, Translate(vec3(300, 160, 10), Test))), 
		SphereSDF(28, Translate(vec3(300, 90, 15), Test))), 
		SphereSDF(6, Translate(vec3(300, 128, 50), Test)))), 
		SphereSDF(20, Translate(vec3(300, 160, 10), Test))), 
		Minus(
		Inter(
		BoxSDF(vec3(100, 100, 60), Translate(vec3(300, 0, 0), Test)), 
		SphereSDF(50, Translate(vec3(300, 0, 0), Test))), 
		SphereSDF(40, Translate(vec3(300, 0, 0), Test)))), 
		SphereSDF(20, Translate(vec3(300, 20, 0), Test))), 
		Minus(
		SphereSDF(50, Translate(vec3(300, -125, 0), Test)), 
		Minus(
		SphereSDF(40, Translate(vec3(300, -125, 45), Test)), 
		SphereSDF(30, Translate(vec3(300, -125, 20), Test)))));
}
