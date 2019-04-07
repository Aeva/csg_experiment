prepend: shaders/draw_box.etc.glsl
prepend: shaders/sdf_common.glsl
prepend: shaders/generated.glsl
--------------------------------------------------------------------------------

in vec4 WorldPosition;
in vec4 WorldNormal;
out vec4 Color;


vec3 Paint(vec3 Position, vec3 Normal, float SDF)
{
	return Normal * vec3(0.5) + vec3(0.5);
}


void main()
{
	const bool SubtractShape = BoxExtent.w < 0.0;
	if (gl_FrontFacing != SubtractShape)
	{
		// The pixel is front facing but the operation is subtract.
		discard;
	}
	else
	{
		const float SDF = GeneratedSDF(WorldPosition.xyz);
		if (SDF > DiscardThreshold)
		{
			// SDF indicates the pixel is outside a volume.
			discard;
		}
		else
		{
			// SDF indicates the pixel is within a volume.
			const float FlipNormal = SubtractShape ? -1.0 : 1.0;
			Color = vec4(Paint(WorldPosition.xyz, WorldNormal.xyz * FlipNormal, SDF), 1.0);
		}
	}
}
