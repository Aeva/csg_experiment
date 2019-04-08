--------------------------------------------------------------------------------

// - - - - Constants - - - -

const float DiscardThreshold = 0.00005;


// - - - - CSG operators - - - -

float Minus(float lhs, float rhs)
{
	return max(lhs, -rhs);
}


float Union(float lhs, float rhs)
{
	return min(lhs, rhs);
}


float Inter(float lhs, float rhs)
{
	return max(lhs, rhs);
}


// - - - - SPACE transformation functions - - - -

vec3 Translate(vec3 NewOrigin, vec3 Cursor)
{
	return Cursor - NewOrigin;
}


vec2 Rotate2D(float Radians, vec2 Cursor)
{
	vec2 SinCos = vec2(sin(Radians), cos(Radians));
	return vec2(
		SinCos.y * Cursor.x + SinCos.x * Cursor.y,
		SinCos.y * Cursor.y - SinCos.x * Cursor.x);
}


vec3 RotateX(float Radians, vec3 Cursor)
{
	vec2 Rotated = Rotate2D(Radians, Cursor.yz);
	return vec3(Cursor.x, Rotated.xy);
}


vec3 RotateY(float Radians, vec3 Cursor)
{
	vec2 Rotated = Rotate2D(Radians, Cursor.xz);
	return vec3(Rotated.x, Cursor.y, Rotated.y);
}


vec3 RotateZ(float Radians, vec3 Cursor)
{
	vec2 Rotated = Rotate2D(Radians, Cursor.xy);
	return vec3(Rotated.xy, Cursor.z);
}


vec3 Scale(vec3 Scale, vec3 Cursor)
{
	return Cursor / Scale;
}


// - - - - SDF shape functions - - - -

float SphereSDF(float Radius, vec3 Cursor)
{
	return length(Cursor) - Radius;
}


float BoxSDF(vec3 Extent, vec3 Cursor)
{
	const vec3 EdgeDistance = abs(Cursor) - Extent * 0.5;
	const vec3 Positive = min(EdgeDistance, vec3(0.0));
	const vec3 Negative = max(EdgeDistance, vec3(0.0));
	const float ExteriorDistance = length(Negative);
	const float InteriorDistance = max(max(Positive.x, Positive.y), Positive.z);
	return ExteriorDistance + InteriorDistance;
}