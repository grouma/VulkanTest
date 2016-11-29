#version 430
#extension GL_ARB_separate_shader_objects : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 view;
    mat4 proj;
	mat4 staticModelView;
	vec3 staticCameraPosition;
	vec4 cameraParameters;
} ubo;
layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) in vec3 position;

layout(location = 0) out vec2 texCoordGeom;
layout(location = 1) out float rayLenGeom;

vec3 reconstructWorldPosition(vec2 ndc, float linear01Depth, mat4 viewMatrix, vec3 cameraPosition, vec4 cameraParameters) {
	float zNear = cameraParameters.z;
	float zFar = cameraParameters.w;
	
	float z = zNear * (1.0 - linear01Depth) + zFar * linear01Depth;
	rayLenGeom = z;

	vec3 xAxis = vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]);
	vec3 yAxis = vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]);
	vec3 zAxis = vec3(viewMatrix[0][2], viewMatrix[1][2], viewMatrix[2][2]);
	
	float scale = z / zNear;
	float scaleX =  scale * ndc.x * cameraParameters.x;
	float scaleY =  scale * ndc.y * cameraParameters.y;

	return vec3(ndc.x, ndc.y, -z);
	// TODO(grouma) - figure out how to make use of initial transform
	// return cameraPosition + scaleX * xAxis + scaleY * yAxis - z * zAxis;
}

void main() {
	texCoordGeom = position.xy * 0.5 + 0.5;

	float depth = texture(texSampler, texCoordGeom).w;
	
	vec3 positionFromDepth = reconstructWorldPosition(position.xy, depth, ubo.staticModelView, ubo.staticCameraPosition, ubo.cameraParameters);

	gl_Position = vec4(positionFromDepth,1);

}