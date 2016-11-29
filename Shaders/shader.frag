#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec2 texCoord;
layout(location = 1) in float rayLen;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) out vec4 outColor;


void main() {
	outColor = texture(texSampler, texCoord.xy);
	outColor.w = 1.0;
}