#ifndef MESH
#define MESH

#include <iostream>
#include <vector>
#include <array>

namespace mesh {
struct Vertex {
    glm::vec3 pos;

    static VkVertexInputBindingDescription getBindingDescription() {
        VkVertexInputBindingDescription bindingDescription = {};
        bindingDescription.binding = 0;
        bindingDescription.stride = sizeof(Vertex);
        bindingDescription.inputRate = VK_VERTEX_INPUT_RATE_VERTEX;

        return bindingDescription;
    }

    static std::array<VkVertexInputAttributeDescription, 1>
    getAttributeDescriptions() {
        std::array<VkVertexInputAttributeDescription, 1> attributeDescriptions = {};

        attributeDescriptions[0].binding = 0;
        attributeDescriptions[0].location = 0;
        attributeDescriptions[0].format = VK_FORMAT_R32G32_SFLOAT;
        attributeDescriptions[0].offset = offsetof(Vertex, pos);

        return attributeDescriptions;
    }
};


static void buildMesh(uint32_t res_x, uint32_t res_y,
                      std::vector<Vertex>& vertices,
                      std::vector<uint32_t>& indices) {
    for (int y = 0; y < res_y; y++) {
        for (int x = 0; x < res_x; x++) {
            float xVal = float(x) / float(res_x) *  2.0f - 1.0f;
            float yVal =  float(y) / float(res_y) * 2.0f - 1.0f;
            vertices.push_back({ {
                    xVal,
                    yVal,
                    0.0f
                }
            });
        }
    }
    for (uint32_t y = 0; y <= res_y - 1; y++) {
        for (uint32_t x = 0; x <= res_x - 1; x++) {
            uint32_t idx00 = y * res_x + x;
            uint32_t idx01 = idx00 + 1;
            uint32_t idx10 = idx00 + res_x;
            uint32_t idx11 = idx10 + 1;

            indices.push_back(idx00);
            indices.push_back(idx01);
            indices.push_back(idx10);

            indices.push_back(idx01);
            indices.push_back(idx11);
            indices.push_back(idx10);
        }
    }
};

}


#endif MESH