#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 position;

layout (location = 0) out vec2 posGeom;

void main() {
	posGeom = position.xy;
}
