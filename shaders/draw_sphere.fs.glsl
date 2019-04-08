prepend: shaders/draw_sphere.etc.glsl
prepend: shaders/sdf_common.glsl
prepend: shaders/generated.glsl
--------------------------------------------------------------------------------

in vec4 ViewCenter;
in vec4 ViewPosition;
in vec2 SpherePosition;
out vec4 Color;


vec3 Paint(vec3 Position, vec3 Normal, float SDF)
{
	return Normal * vec3(0.5) + vec3(0.5);
}


void main()
{
	const float BisectDot = dot(SpherePosition, SpherePosition);
	if (BisectDot > 1.0)
	{
		discard;
	}
	else
	{
		const float Dir = SphereParams.w >= 0.0 ? -1.0 : 1.0;
		const float Offset = sqrt(1 - BisectDot) * abs(SphereParams.w);
		const float NewDepth = Offset * Dir + ViewPosition.z;
		const vec4 NewViewPosition = vec4(ViewPosition.xy, NewDepth, 1);
		const vec4 WorldPosition = InvViewMatrix * NewViewPosition;
		const vec3 ViewNormal = normalize(NewViewPosition.xyz - ViewCenter.xyz);
		const vec3 WorldNormal = normalize(WorldPosition.xyz - SphereParams.xyz) * Dir;
		const float SDF = GeneratedSDF(WorldPosition.xyz);
		if (SDF > DiscardThreshold)
		{
			discard;
		}
		else
		{
			Color = vec4(Paint(WorldPosition.xyz, WorldNormal, SDF), 1.0);
			if (ViewToClip.z != 0.0)
			{
				gl_FragDepth = 1.0 - (1.0/NewDepth);
			}
			else
			{
				const vec4 NewClip = PerspectiveMatrix * NewViewPosition;
				gl_FragDepth = NewClip.z / NewClip.w;
			}
		}
	}
}
