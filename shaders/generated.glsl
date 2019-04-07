--------------------------------------------------------------------------------

float GeneratedSDF(vec3 Test)
{
	return Minus(
		Minus(
		Minus(
		BoxSDF(vec3(200, 200, 200), Translate(vec3(0, -20, 0), Test)), 
		BoxSDF(vec3(150, 150, 400), Translate(vec3(0, -20, 0), Test))), 
		BoxSDF(vec3(150, 400, 150), Translate(vec3(0, -20, 0), Test))), 
		BoxSDF(vec3(400, 150, 150), Translate(vec3(0, -20, 0), Test)));
}
