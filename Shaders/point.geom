#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (points) in;
layout (points,  max_vertices=1) out;

in vec2 texCoordGeom[];

layout(binding = 0) uniform UniformBufferObject {
    mat4 modelView;
	vec3 quantization;
	float threshold;
} ubo;

layout(location = 0) out vec2 texCoord;

void main() {
		vec4 position = gl_in[0].gl_Position;
		gl_Position = ubo.modelView * gl_in[0].gl_Position;
		texCoord = texCoordGeom[0];
		EmitVertex();
}

