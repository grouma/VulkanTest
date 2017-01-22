#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 modelView;
	mat4 inverseStaticModelView;
	float quantization;
} ubo;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec3 position;

layout(location = 0) out vec2 texCoordGeom;

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

float getDepth(vec2 pos) {
	float depth = texture(texSampler, pos * 0.5 + 0.5).w;
	float gamma = ubo.quantization;
	depth = pow(depth, 4);

	return depth;
}

vec3 reconstructWorldPosition(vec2 ndc, float depth) {
	vec3 planePosition = unproject(ndc);
	return depth * normalize(planePosition);
}

void main() {
	texCoordGeom = position.xy * 0.5 + 0.5;

	float depth = texture(texSampler, texCoordGeom).w;

	vec3 positionFromDepth = reconstructWorldPosition(position.xy, depth);
	gl_Position = vec4(positionFromDepth,1);
}