#version 430

layout (triangles) in;
layout (triangle_strip,  max_vertices=3) out;

in vec2 texCoordGeom[];
in float rayLenGeom[];

layout(binding = 0) uniform UniformBufferObject {
    mat4 view;
    mat4 proj;
	mat4 staticModelView;
	vec3 staticCameraPosition;
	vec4 cameraParameters;
} ubo;

layout(location = 0) out vec2 texCoord;
layout(location = 1) out float rayLen;

void main() {
	float dist0 = length(gl_in[0].gl_Position.xyz - gl_in[1].gl_Position.xyz);
	float dist1 = length(gl_in[1].gl_Position.xyz - gl_in[2].gl_Position.xyz);
	float dist2 = length(gl_in[0].gl_Position.xyz - gl_in[2].gl_Position.xyz);
	
	float maxDist = max(dist0, max(dist1, dist2));
	
	if(maxDist < 1) {
		gl_Position = ubo.proj * ubo.view * gl_in[0].gl_Position;
		texCoord = texCoordGeom[0];
		rayLen = rayLenGeom[0];
		EmitVertex();

		gl_Position = ubo.proj * ubo.view * gl_in[1].gl_Position;
		texCoord = texCoordGeom[1];
		rayLen = rayLenGeom[1];
		EmitVertex();

		gl_Position = ubo.proj * ubo.view * gl_in[2].gl_Position;
		texCoord = texCoordGeom[2];
		rayLen = rayLenGeom[2];
		EmitVertex();
		EndPrimitive();
	}
}