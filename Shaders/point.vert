#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 modelView;
	vec3 quantization;
	float threshold;
} ubo;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec3 position;

layout(location = 0) out vec2 texCoordGeom;

vec4 positionFromDepth(vec2 win, float depth) {
	float scale = sqrt(1 - win.y * win.y);
	float x = win.x * scale;
	float y = win.y;
	float z = 1.0 - x * x - y * y; 
	vec3 hemiPos = vec3(x,y,sqrt(z)) * depth;
	if(z>ubo.threshold){
		return vec4(hemiPos, 1.0);
	}else{
		return vec4(0);
	}
	
}

float getDepth(vec2 position) {
	float depth = texture(texSampler, position * 0.5 + 0.5).w;
	float minDepth = ubo.quantization.x;
	float maxDepth = ubo.quantization.y;
	depth = pow(depth, ubo.quantization.z);
	depth = depth * (maxDepth - minDepth) + minDepth;
	return depth;
}

void main() {
	texCoordGeom = position.xy * 0.5 + 0.5;

	float depth = getDepth(position.xy);

	gl_Position = positionFromDepth(position.xy, depth);
}