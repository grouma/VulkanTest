#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 view;
    mat4 proj;
	mat4 staticModelView;
} ubo;
layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec3 position;

layout(location = 0) out vec2 texCoordGeom;

vec3 unproject(vec3 win, mat4 modelviewMatrix) {
	vec4 outVals = inverse(modelviewMatrix) * vec4(win.x, win.y, 2.0f * win.z - 1.0f, 1.0);
	return vec3(-outVals[0], outVals[1], outVals[2]) / outVals.w;
}

vec3 lookAtToCameraPosition(mat4 mat) {
	return transpose(mat3(mat)) * -vec3(mat[3][0], mat[3][1], mat[3][2]);
}

vec3 reconstructWorldPosition(vec2 ndc, float rayLength, mat4 modelviewMatrix) {
	vec3 staticCameraPosition = lookAtToCameraPosition(modelviewMatrix);
	vec3 planePosition = unproject(vec3(ndc, 1), modelviewMatrix);
	vec3 ray = rayLength * normalize(planePosition - staticCameraPosition);
	return staticCameraPosition + ray;
}

void main() {
	texCoordGeom = position.xy * 0.5 + 0.5;

	float depth = texture(texSampler, texCoordGeom).w;

	vec3 positionFromDepth = reconstructWorldPosition(position.xy, depth, ubo.staticModelView);
	gl_Position = vec4(positionFromDepth,1);
}