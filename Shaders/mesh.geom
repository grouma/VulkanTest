#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (triangles) in;
layout (triangle_strip,  max_vertices = 6) out;

layout(binding = 0) uniform UniformBufferObject {
    mat4 modelView;
	mat4 inverseStaticModelView;
	float quantization;
} ubo;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec2 posGeom[];

layout(location = 0) out vec2 texCoord;

bool hasZeroDepth = false;
float minDepth = 0;
float maxDepth = 1.0;

vec3 unproject(vec2 win) {
	float z = -sqrt(1 - win.x * win.x - win.y * win.y); 
	if(z < 0){
		float scale = 1 - win.y * win.y;
		// Scale x to account for hemisphere projection and invert y to account for vulkan
		// coordinate system.
		vec4 outVals = ubo.inverseStaticModelView * vec4(win.x * (scale), -win.y, z, 1.0);
		return vec3(outVals[0], outVals[1], outVals[2]) / outVals.w;
	}else
		return vec3(0);
	
}

vec3 reconstructWorldPosition(vec2 ndc, float depth) {
	vec3 planePosition = unproject(ndc);
	return depth * normalize(planePosition);
}

float getDepth(int idx) {
	float depth = texture(texSampler, posGeom[idx] * 0.5 + 0.5).w;
	if(depth == 0)
		hasZeroDepth = true;

	depth = pow(depth, ubo.quantization);
	return depth;
}

void emitPosition(int idx, float depth) {
	vec2 pos = posGeom[idx].xy;
	texCoord = pos * 0.5 + 0.5;

	vec3 positionFromDepth = reconstructWorldPosition(pos, depth);
	gl_Position = ubo.modelView * vec4(positionFromDepth,1);
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
		
		float thres = 0.1;
		
		if(minDist / avgDepth < thres ) {
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