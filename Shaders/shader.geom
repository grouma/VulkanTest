#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (points) in;
layout (points,  max_vertices=1) out;

in vec2 texCoordGeom[];

layout(binding = 0) uniform UniformBufferObject {
    mat4 view;
    mat4 proj;
	mat4 staticModelView;
} ubo;

layout(location = 0) out vec2 texCoord;

void main() {
		gl_Position = ubo.proj * ubo.view * gl_in[0].gl_Position;
		texCoord = texCoordGeom[0];
		EmitVertex();
}