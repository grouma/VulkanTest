#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (triangles) in;
layout (triangle_strip,  max_vertices = 6) out;

layout(binding = 0) uniform UniformBufferObject {
    mat4 modelView;
	vec3 quantization;
	float threshold;
} ubo;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec2 posGeom[];

layout(location = 0) out vec2 texCoord;

bool hasZeroDepth = false;

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

float getDepth(int idx) {
	float depth = texture(texSampler, posGeom[idx] * 0.5 + 0.5).w;
	if(depth == 0)
		hasZeroDepth = true;

	float minDepth = ubo.quantization.x;
	float maxDepth = ubo.quantization.y;
	depth = pow(depth, ubo.quantization.z);
	depth = depth * (maxDepth - minDepth) + minDepth;
	return depth;
}

void emitPosition(int idx, float depth) {
	vec2 pos = posGeom[idx].xy;
	texCoord = pos * 0.5 + 0.5;

	gl_Position = ubo.modelView * positionFromDepth(pos, depth);
	EmitVertex();
}

void main() {
	float d0 = getDepth(0);
	float d1 = getDepth(1);
	float d2 = getDepth(2);
	
	if(!hasZeroDepth) {
		float minDepth = min(d0, min(d1, d2));
		float maxDepth = max(d0, max(d1, d2));
		float minDist = maxDepth - minDepth;

		float avgDepth = (d0 + d1 + d2) / 3.0;
		
		if(minDist / avgDepth < ubo.threshold) {
			emitPosition(0, d0);
			emitPosition(1, d1);
			emitPosition(2, d2);
		} else {
			emitPosition(0, maxDepth);
			emitPosition(1, maxDepth);
			emitPosition(2, maxDepth);
		}
	}
}