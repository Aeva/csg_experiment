#version 420
#extension GL_ARB_compute_shader : require
#extension GL_ARB_shader_storage_buffer_object : require
#extension GL_ARB_shader_image_load_store : require
#extension GL_ARB_gpu_shader5 : require
#extension GL_ARB_shading_language_420pack : require


layout(std140, binding = 0) uniform CSGUniformsBlock
{
	uint RegionCount;
	mat4 Projection;
};


layout(std430, binding = 1) buffer DispatchControlBlock
{
	uint VertexCount;
	uint InstanceCount;
	uint First;
  	uint BaseInstance;
} DispatchControl;


struct CSGRegion
{
	vec3 BoundsMin;
	vec3 BoundsMax;
};
layout(std430, binding = 2) buffer RegionDataBlock
{
	CSGRegion Regions[];
} RegionData;


layout(std430, binding = 3) buffer OutputPlanesBlock
{
	// x: CenterX;
	// y: CenterY;
	// z: XYExtent;
	// w: Depth;
	vec4 Params[];
} OutputPlanes;


layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
void main()
{
	if (gl_GlobalInvocationID.x == 0)
	{
		DispatchControl.InstanceCount = 0;
	}
	memoryBarrierBuffer();
	if (gl_GlobalInvocationID.x < RegionCount)
	{
		const CSGRegion Region = RegionData.Regions[gl_GlobalInvocationID.x];
	
		const float X1 = Region.BoundsMin.x;
		const float Y1 = Region.BoundsMin.y;
		const float Z1 = Region.BoundsMin.z;
		const float X2 = Region.BoundsMax.x;
		const float Y2 = Region.BoundsMax.y;
		const float Z2 = Region.BoundsMax.z;

		const vec4 Corners[8] = {
			vec4(X1, Y1, Z1, 1),
			vec4(X1, Y1, Z2, 1),
			vec4(X1, Y2, Z1, 1),
			vec4(X1, Y2, Z2, 1),
			vec4(X2, Y1, Z1, 1),
			vec4(X2, Y1, Z2, 1),
			vec4(X2, Y2, Z1, 1),
			vec4(X2, Y2, Z2, 1)
		};

		vec4 ProjectedMin = Projection * Corners[0];
		vec4 ProjectedMax = ProjectedMin;
		for (int i=1; i<8; ++i)
		{
			vec4 Projected = Projection * Corners[i];
			ProjectedMin = min(Projected, ProjectedMin);
			ProjectedMax = min(Projected, ProjectedMax);
		}

		
		// lol idk
		bool bCullingPassed = Region.BoundsMin.x <= Region.BoundsMax.x;

		if (bCullingPassed)
		{
			uint NewPlanes = 1;
			const uint EndOffset = atomicAdd(DispatchControl.InstanceCount, NewPlanes);
			const uint StartOffset = EndOffset - NewPlanes;
		}
	}
}
