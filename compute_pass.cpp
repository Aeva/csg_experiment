
#include "compute_pass.h"
using namespace CullingPass;


const unsigned int RegionCount = 1;

ShaderProgram CSGCullingProgram;
GLuint RegionBuffer;
GLuint CullingUniformBuffer;
GLuint IndirectParamsBuffer;


void SetupCullingUniforms()
{
	CullingUniforms Uniforms;
	Uniforms.RegionCount = RegionCount;
	/*Uniforms.Projection = {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	};*/
	glGenBuffers(1, &CullingUniformBuffer);
	glBindBuffer(GL_UNIFORM_BUFFER, CullingUniformBuffer);
	glBufferData(GL_UNIFORM_BUFFER, sizeof(CullingUniforms), &Uniforms, GL_STATIC_DRAW);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}


void SetupCullingAABBs()
{
	CSGRegion TestRegionData;
 	glGenBuffers(1, &RegionBuffer);
 	glBindBuffer(GL_SHADER_STORAGE_BUFFER, RegionBuffer);
	glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(CSGRegion), &TestRegionData, GL_STATIC_DRAW);
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0);
}


void SetupIndirectRenderingParams()
{
	DrawArraysIndirectCommand IndirectParams;
	IndirectParams.VertexCount = 4;
	IndirectParams.InstanceCount = 0;
	IndirectParams.First = 0;
	IndirectParams.BaseInstance = 0;
	glGenBuffers(1, &IndirectParamsBuffer);
	glBindBuffer(GL_DRAW_INDIRECT_BUFFER, IndirectParamsBuffer);
	glBufferData(GL_DRAW_INDIRECT_BUFFER, sizeof(DrawArraysIndirectCommand), &IndirectParams, GL_STATIC_DRAW);
	glBindBuffer(GL_DRAW_INDIRECT_BUFFER, 0);
}


bool CullingPass::Setup()
{
	SetupCullingUniforms();
	SetupCullingAABBs();
	SetupIndirectRenderingParams();
	
	return CSGCullingProgram.ComputeCompile("shaders/example.glsl");
}


void CullingPass::Dispatch()
{
	glUseProgram(CSGCullingProgram.ProgramID);
	glBindBuffer(GL_DRAW_INDIRECT_BUFFER, 0);
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, IndirectParamsBuffer);
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, RegionBuffer);
	glDispatchCompute(FAST_DIV_ROUND_UP(RegionCount, 64), 1, 1);
	glMemoryBarrier(GL_SHADER_STORAGE_BARRIER_BIT | GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

	glBindBuffer(GL_DRAW_INDIRECT_BUFFER, IndirectParamsBuffer);
}