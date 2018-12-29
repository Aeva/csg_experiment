#include "10_volume_setup/common.glsl"

// Group size is arbitrary.
// Each thread is a tile.
layout(local_size_x = 4, local_size_y = 4, local_size_z = 1) in;
void main()
{
	const vec3 TileMin = vec3(vec2(gl_GlobalInvocationID.xy*TILE_SIZE), 0);
	const vec3 TileExtent = vec3(TILE_SIZE, TILE_SIZE, 1024) * 0.5;
	const vec3 TileCenter = TileMin + TileExtent;
	const uint TileID = ((gl_GlobalInvocationID.x << TILE_X_OFFSET) & TILE_X_MASK) | (gl_GlobalInvocationID.y & TILE_Y_MASK);

	int HeadChunk = -1;
	int LastChunk = -1;
	float StartDepth = 0;
	float EndDepth = -1;
	uint PathDepth = 0;

	// Generously assuming that the bounds list is sorted front to back.
	for (uint i=0; i<PositiveSpace.Count; ++i)
	{
		const Bounds Test = PositiveSpace.Data[i];

		// This could be tightened a bit for spheres.
		const float Near = clamp(Test.Center.z - Test.Extent.z, 0, 1024);
		const float Far = clamp(Test.Center.z + Test.Extent.z, 0, 1024);
		//const bool bAccepted = Far >= 0 && TestAABBOverlap(TileCenter, TileExtent, Test.Center.xyz, Test.Extent.xyz);
		const bool bAccepted = Far >= 0 && TestAABBSphereOverlap(TileCenter, TileExtent, Test.Center.xyz, Test.Extent.w);
		if (bAccepted)
		{
			if (EndDepth < 0)
			{
				StartDepth = Near;
				EndDepth = Far;
			}
			else if (Near <= EndDepth)
			{
				StartDepth = min(StartDepth, Near);
				EndDepth = max(EndDepth, Far);
			}
			else
			{
				++PathDepth;
				const int WriteIndex = int(atomicAdd(ActiveRegions.Count, 1));
				ActiveRegions.Data[WriteIndex].TileID = TileID;
				ActiveRegions.Data[WriteIndex].StartDepth = StartDepth;
				ActiveRegions.Data[WriteIndex].EndDepth = EndDepth;
				ActiveRegions.Data[WriteIndex].NextRegion = -1;
				if (LastChunk == -1)
				{
					HeadChunk = WriteIndex;
				}
				else
				{
					ActiveRegions.Data[LastChunk].NextRegion = WriteIndex;
				}
				LastChunk = WriteIndex;

				StartDepth = Near;
				EndDepth = Far;
			}
		}
	}

	if (EndDepth > -1)
	{
		++PathDepth;
		const int WriteIndex = int(atomicAdd(ActiveRegions.Count, 1));
		ActiveRegions.Data[WriteIndex].TileID = TileID;
		ActiveRegions.Data[WriteIndex].StartDepth = StartDepth;
		ActiveRegions.Data[WriteIndex].EndDepth = EndDepth;
		ActiveRegions.Data[WriteIndex].NextRegion = -1;
		if (LastChunk == -1)
		{
			HeadChunk = WriteIndex;
		}
		else
		{
			ActiveRegions.Data[LastChunk].NextRegion = WriteIndex;
		}
	}

	imageStore(TileListHead, ivec2(gl_GlobalInvocationID.xy), ivec4(HeadChunk, PathDepth, 0, 0));
	/*
	if (HeadChunk > -1)
	{
		const uint Lanes = TILE_SIZE*TILE_SIZE;
		const uint WriteIndex = atomicAdd(WorkItems.Count, Lanes);
		for (uint i=0; i<Lanes; ++i)
		{
			const uint LanePart = (i<<LANE_OFFSET) & LANE_MASK;
			const uint WorkPart = uint(HeadChunk) & WORK_MASK;
			WorkItems.PackedData[WriteIndex+i] = LanePart | WorkPart;
		}
		atomicMax(ActiveRegions.LongestPath, PathDepth);
	}
	*/
}
