#ifndef CAMERA
#define CAMERA

#define GLFW_INCLUDE_VULKAN
#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <GLFW/glfw3.h>

class Camera {
  public:
    glm::vec3 cameraPos = glm::vec3(0, 0, 0);
    glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, 1.0f);
    glm::vec3 cameraUp = glm::vec3(0.0f, -1.0f, 0.0f);

    Camera(int width, int height) {
        lastX = width / 2;
        lastY = height / 2;
        setViewChanged(true);
    };

    bool viewChanged() {
        return _viewChanged;
    }

    void setViewChanged(bool newValue) {
        _viewChanged = newValue;
    }

    void handleMouseButton(int button, int action) {
        if (button == GLFW_MOUSE_BUTTON_LEFT) {
            _buttonDown = action == GLFW_PRESS;
        }
    }

    void handleMouseInput(double xpos, double ypos) {
        float xoffset = xpos - lastX;
        float yoffset = ypos - lastY;

        if (xoffset == 0 && yoffset == 0) return;

        lastX = xpos;
        lastY = ypos;
        if (_buttonDown) {
            xoffset *= _sensitivity;
            yoffset *= _sensitivity;

            yaw += xoffset;
            pitch += yoffset;

            if (pitch > 89.0f)
                pitch = 89.0f;
            if (pitch < -89.0f)
                pitch = -89.0f;

            glm::vec3 front;


            front.x = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
            front.y = sin(glm::radians(pitch));
            front.z = cos(glm::radians(yaw)) * cos(glm::radians(pitch));

            cameraFront = glm::normalize(front);

            setViewChanged(true);
        }
    }

    void handleKeyInput(int key) {
        float cameraSpeed = 0.5f;
        if (key == GLFW_KEY_W)
            cameraPos += cameraSpeed * cameraFront;
        if (key == GLFW_KEY_S)
            cameraPos -= cameraSpeed * cameraFront;
        if (key == GLFW_KEY_A)
            cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
        if (key == GLFW_KEY_D)
            cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;

        setViewChanged(true);
    }

  private:
    float lastX, lastY, yaw = 0, pitch = 0;
    bool _viewChanged = false;
    bool _buttonDown = false;
    float _sensitivity = 0.20f;

};

#endif CAMERA