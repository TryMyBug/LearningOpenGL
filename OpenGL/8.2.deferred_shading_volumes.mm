//
//  main.m
//  OpenGL
//
//  Created by wxh on 2018/11/27.
//  Copyright © 2018 wxh. All rights reserved.
//
#include <iostream>
#include <cmath>

#include <glad/glad.h>
#include <GLFW/glfw3.h>

//#include "assimp/scene.h"
//#include "assimp/postprocess.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include <vector>

#include "Shader.hpp"
#include "Camera.hpp"
#include "Texture.hpp"

#include "DirectionLight.hpp"
#include "PointLight.hpp"
#include "Spotlight.hpp"
#include "Mesh.hpp"
#include "Model.hpp"


const unsigned int SCR_WIDTH = 1600;
const unsigned int SCR_HEIGHT = 1200;

bool isLineModel = false;

float mixValue = 0.5;
float x = 0.0f;
float y = 0.0f;
float z = -3.0f;

float fov = 45.0f;

float speed = 25.0f;

float deltaTime = 0.0f; //当前帧与上一帧的时间差
float lastFrame = 0.0f; //上一帧的时间

float lastX = SCR_WIDTH / 2.0f;
float lastY = SCR_HEIGHT / 2.0f;

float pitch = 0.0f;
float yaw = 0.0f;

float shininess = 5.0f;
float specularStrength = 0.5f;
float heightScale = 0.1f;

bool firstMouse = true;

bool isBlinn = true;

bool hasBloom = false;

float exposure = 1.0f;

glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, 1.0f);
glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);

Camera camera(glm::vec3(0.0f, 0.0f, 0.0f));

bool hasDisplacement = true;

//窗口大小改变的回调
void framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
    glViewport(0, 0, width, height);
}
//处理输入事件
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_1) == GLFW_PRESS) {
        isLineModel = true;
        if (isLineModel) {
            isLineModel = false;
//            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            isBlinn = false;
            hasBloom = false;
            hasDisplacement = false;
            std::cout << "关闭bloom" << shininess << std::endl;
        }
    }
    if (glfwGetKey(window, GLFW_KEY_2) == GLFW_PRESS) {
        isLineModel = false;
        if (!isLineModel) {
            isLineModel = true;
//            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            isBlinn = true;
            
            hasBloom = true;
            hasDisplacement = true;
            
            std::cout << "开启bloom" << shininess << std::endl;
        }
    }
    
    if (glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS) {
//        mixValue -= 0.001f;
//
//        if (mixValue <= 0.0f) {
//            mixValue = 0.0f;
//        }
        shininess -= 0.1f;
        if (shininess <= 1.0f) {
            shininess = 1.0f;
        }
        std::cout << "shininess: " << shininess << std::endl;
    }
    if (glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS) {
        specularStrength -= 0.001f;

        if (specularStrength <= 0.0f) {
            specularStrength = 0.0f;
        }
    }
    
    if (glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS) {
        specularStrength += 0.001f;
        if (specularStrength >= 1.0f) {
            specularStrength = 1.0f;
        }
    }
    if (glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) {
        //        mixValue += 0.001f;
        //
        //        if (mixValue >= 1.0f) {
        //            mixValue = 1.0f;
        //        }
        shininess += 0.1f;
        if (shininess >= 100.0f) {
            shininess = 100.0f;
        }
        std::cout << "shininess: " << shininess << std::endl;
    }
    
    if (glfwGetKey(window, GLFW_KEY_0) == GLFW_PRESS) {
        if (exposure > 0.0f) {
            exposure -= 0.01f;
        } else {
            exposure = 0.0f;
        }
        std::cout << "heightScale: " << exposure << std::endl;
    }
    if (glfwGetKey(window, GLFW_KEY_9) == GLFW_PRESS) {
        if (exposure < 5.0f) {
            exposure += 0.01f;
        } else {
            exposure = 5.0f;
        }
        std::cout << "heightScale: " << exposure << std::endl;
    }
    
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.keyboardMove(MoveDirectionForward, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.keyboardMove(MoveDirectionBackwrad, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
         camera.keyboardMove(MoveDirectionLeft, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.keyboardMove(MoveDirectionRight, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
        camera.keyboardMove(MoveDirectionUp, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS)
        camera.keyboardMove(MoveDirectionDown, deltaTime);
}

void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    if (firstMouse) {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
    
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;
    
    lastX = xpos;
    lastY = ypos;
    
    camera.mouseMove(xoffset, yoffset);
}

void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    camera.mouseScroll(yoffset);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        glfwInit();
        
        //初始化GLFW
        //glfwWindowHint函数的第一个参数代表选项的名称，第二个参数是设置第一项的值
        //GLFW_CONTEXT_VERSION_MAJOR使用的主版本号：3
        //GLFW_CONTEXT_VERSION_MINOR使用的次版本号：3
        //所以告诉GLFW我们要使用的OpenGl的版本号是3.3
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        //GLFW_OPENGL_PROFILE指定开发模式是核心模式,去掉了向后兼容的特性
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
//        glfwWindowHint(GLFW_SAMPLES, 4);
        
        GLFWwindow *window = glfwCreateWindow(SCR_WIDTH/2.0, SCR_HEIGHT/2.0, "LearnOpenGL", NULL, NULL);
        if (window == NULL) {
            std::cout << "Failed to create GLFW window" << std::endl;
            glfwTerminate();
            return -1;
        }
        glfwMakeContextCurrent(window);
//        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
        
        //在调用任何OpenGL的函数之前我们需要初始化GLAD
        if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
            std::cout << "Faild to initialize GLAD" << std::endl;
            return -1;
        }
        
        glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
        glfwSetCursorPosCallback(window, mouse_callback);
        glfwSetScrollCallback(window, scroll_callback);
        
        int nrAttributes;
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
        std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

        Shader gBufferShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/gBufferShader.vs",
                            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/gBufferShader.fs");
        
        Shader lightShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/light.vs",
                           "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/light.fs");
        
        Shader skyboxShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/skybox.vs",
                            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/skybox.fs");
        
        Shader blurShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/bloomBlur.vs",
                          "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/bloomBlur.fs");
        
        Shader lightingPassShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/lightingPassShader.vs",
                                  "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/lightingPassShader.fs");
        
        Shader objectShader("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/object.vs",
                            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Shaders/object.fs");
        
        
        std::vector<std::string> faces{
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/right.jpg",
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/left.jpg",
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/top.jpg",
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/bottom.jpg",
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/front.jpg",
            "/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/skybox/back.jpg",
        };

        Texture cubeMap(faces);
        
        Texture diffuseMap("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/wood.png");
        Texture normalMap("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/bricks2_normal.jpg");
        Texture containerMap("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/container.jpg");
        
        Texture awesomeMap("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/textures/awesomeface.png");
        

        skyboxShader.setInt("skybox", 0);
        blurShader.setInt("image", 0);
        
        lightingPassShader.setInt("gPosition", 0);
        lightingPassShader.setInt("gNormal", 1);
        lightingPassShader.setInt("gAlbedoSpec", 2);
        
        gBufferShader.setInt("skybox", 1);
        gBufferShader.setInt("diffuseMap", 4);
        objectShader.setInt("texture_face", 4);
        
        Model skybox(GeometrySkybox);
        Model screen(GeometryScreen);
        Model box(GeometryCube);
        Model nanosuit("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/objects/nanosuit/nanosuit.obj");
        Model plane(GeometryPlane);
        Model planet("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/objects/planet/planet.obj");
        
        Model gltfBox("/Users/wxh/Git/GitHub/LearningOpenGL/OpenGL/Resources/objects/Cube/glTF/Cube.gltf");
        
        std::vector<glm::vec3> objectPositions;
        objectPositions.push_back(glm::vec3(-10.0, 0.0, -10.0));
        objectPositions.push_back(glm::vec3( -5.0, 0.0, -10.0));
        objectPositions.push_back(glm::vec3(  0.0,  0.0, -10.0));
        objectPositions.push_back(glm::vec3(  5.0,  0.0, -10.0));
        objectPositions.push_back(glm::vec3( 10.0,  0.0, -10.0));
        
        objectPositions.push_back(glm::vec3(-10.0,  0.0, -5.0));
        objectPositions.push_back(glm::vec3( -5.0,  0.0, -5.0));
        objectPositions.push_back(glm::vec3(  0.0,  0.0, -5.0));
        objectPositions.push_back(glm::vec3(  5.0,  0.0, -5.0));
        objectPositions.push_back(glm::vec3( 10.0,  0.0, -5.0));
        
        objectPositions.push_back(glm::vec3(-10.0,  0.0, 0.0));
        objectPositions.push_back(glm::vec3( -5.0,  0.0, 0.0));
        objectPositions.push_back(glm::vec3(  0.0,  0.0, 0.0));
        objectPositions.push_back(glm::vec3(  5.0,  0.0, 0.0));
        objectPositions.push_back(glm::vec3( 10.0,  0.0, 0.0));
        
        objectPositions.push_back(glm::vec3(-10.0,  0.0, 5.0));
        objectPositions.push_back(glm::vec3( -5.0,  0.0, 5.0));
        objectPositions.push_back(glm::vec3(  0.0,  0.0, 5.0));
        objectPositions.push_back(glm::vec3(  5.0,  0.0, 5.0));
        objectPositions.push_back(glm::vec3( 10.0,  0.0, 5.0));
        
        objectPositions.push_back(glm::vec3(-10.0,  0.0, 10.0));
        objectPositions.push_back(glm::vec3( -5.0,  0.0, 10.0));
        objectPositions.push_back(glm::vec3(  0.0,  0.0, 10.0));
        objectPositions.push_back(glm::vec3(  5.0,  0.0, 10.0));
        objectPositions.push_back(glm::vec3( 10.0,  0.0, 10.0));
        
        const unsigned int NR_LIGHTS = 50;
        std::vector<glm::vec3> lightPositions;
        std::vector<glm::vec3> lightColors;
        srand(13);
        for (unsigned int i = 0; i < NR_LIGHTS; i++)
        {
            // calculate slightly random offsets
            float xPos = ((rand() % 100) / 100.0) * 12.0 - 6.0;
            float yPos = ((rand() % 100) / 100.0) * 12.0 - 6.0;
            float zPos = ((rand() % 100) / 100.0) * 12.0 - 6.0;
            lightPositions.push_back(glm::vec3(xPos, yPos, zPos));
            // also calculate random color
            float rColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
            float gColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
            float bColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
            lightColors.push_back(glm::vec3(rColor, gColor, bColor));
        }
        
//        把顶点着色器的Uniform块设置为绑定点0
        gBufferShader.setBlockBindingPoint("Matrices", 0);
        skyboxShader.setBlockBindingPoint("Matrices", 0);
        lightShader.setBlockBindingPoint("Matrices", 0);
        objectShader.setBlockBindingPoint("Matrices", 0);
        
        //生成一个FBO
        GLuint gBuffer;
        glGenFramebuffers(1, &gBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, gBuffer);
        
        GLuint gPosition, gNormal, gAlbedoSpec;
        
        //position
        glGenTextures(1, &gPosition);
        glBindTexture(GL_TEXTURE_2D, gPosition);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, SCR_WIDTH, SCR_HEIGHT, 0, GL_RGB, GL_FLOAT, NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        glBindTexture(GL_TEXTURE_2D, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, gPosition, 0);
        
        //normal
        glGenTextures(1, &gNormal);
        glBindTexture(GL_TEXTURE_2D, gNormal);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, SCR_WIDTH, SCR_HEIGHT, 0, GL_RGB, GL_FLOAT, NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glBindTexture(GL_TEXTURE_2D, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, gNormal, 0);
        
        //color、specular
        glGenTextures(1, &gAlbedoSpec);
        glBindTexture(GL_TEXTURE_2D, gAlbedoSpec);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, SCR_WIDTH, SCR_HEIGHT, 0, GL_RGBA, GL_FLOAT, NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, gAlbedoSpec, 0);
        
        //告诉OpenGL我们将要使用帧缓冲的哪种附件来进行渲染
        GLuint attachments[3] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2};
        glDrawBuffers(3, attachments);
        
        unsigned int rbo;
        glGenRenderbuffers(1, &rbo);
        glBindRenderbuffer(GL_RENDERBUFFER, rbo);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, SCR_WIDTH, SCR_HEIGHT);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            std::cout << "ERROR::FRAMEBUFFER:: Framebuffer is not complete!" << std::endl;
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        //开启MSAA
//        glEnable(GL_MULTISAMPLE);
        
        //创建ubo
        unsigned int uboMatrices;
        //创建
        glGenBuffers(1, &uboMatrices);
        glBindBuffer(GL_UNIFORM_BUFFER, uboMatrices);
        glBufferData(GL_UNIFORM_BUFFER, 2 * sizeof(glm::mat4), NULL, GL_STATIC_DRAW);
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
        glBindBufferRange(GL_UNIFORM_BUFFER, 0, uboMatrices, 0, 2 * sizeof(glm::mat4));

        //启用深度测试
        glEnable(GL_DEPTH_TEST);
        //在片段深度值小于缓冲的深度值时通过测试
        glDepthFunc(GL_LESS);

        //开启混合
//        glEnable(GL_BLEND);

        //设置混合因子
//        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

//        也可以使用glBlendFuncSeparate为RGB和alpha通道分别设置不同的选项
//        glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);

//        设置运算符
//        glBlendEquation(GL_FUNC_ADD);
        
        //启用面剔除
        glEnable(GL_CULL_FACE);

        //设置剔除背面
        glCullFace(GL_BACK);

        //指定逆时针环绕顺序为前面
        //GL_CCW：逆时针环绕顺序
        //GL_CW：顺时针环绕顺序
//        glFrontFace(GL_CCW);
        
        //使用while循环来不断的渲染画面，我们称之为渲染循环（Render Loop）
        //没次循环开始之前检查一次GLFW是否被要求退出
        
        float lastTime = glfwGetTime();
        int times = 0;
        float nowTime = lastTime;
        
        while (!glfwWindowShouldClose(window)) {
            float currentFrame = glfwGetTime();
            deltaTime = currentFrame - lastFrame;
            lastFrame = currentFrame;
            
            //输入
            processInput(window);

//            lightPos.z = sin(glfwGetTime() * 0.5) * 3.0;
            times += 1;
            nowTime = glfwGetTime();
            if ((nowTime - lastTime) >= 1.0) {
                std::cout << "FPS: " << times << ", lastTime: " << lastTime << ", nowTime: " <<nowTime << std::endl;
                lastTime = nowTime;
                times = 0;
            }
            
            
            
            //渲染指令
            glClearColor(0.0, 0.0, 0.0, 1.0f);

            //glClear是一个状态使用函数，清除颜色缓冲、深度缓冲、模板缓冲
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glBindFramebuffer(GL_FRAMEBUFFER, gBuffer);
            
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//            glCullFace(GL_BACK);
            glEnable(GL_DEPTH_TEST);
//            glEnable(GL_BLEND);
            
            //禁用深度写入
            //            glDepthMask(GL_FALSE);
            
            glm::mat4 view = camera.viewMatrix();
            glm::mat4 projection = glm::perspective(glm::radians(fov), (float)SCR_WIDTH/(float)SCR_HEIGHT, 0.1f, 100.0f);

            //为ubo填充数据
            glBindBuffer(GL_UNIFORM_BUFFER, uboMatrices);//把uboMatrices绑定Uniform缓冲
            glBufferSubData(GL_UNIFORM_BUFFER, 0, sizeof(glm::mat4), glm::value_ptr(view));//根据block中的布局先设置view，再设置projection
            glBufferSubData(GL_UNIFORM_BUFFER, sizeof(glm::mat4), sizeof(glm::mat4), glm::value_ptr(projection));
//            glBufferSubData(GL_UNIFORM_BUFFER, 2 * sizeof(glm::mat4), sizeof(glm::mat4), glm::value_ptr(lightSpaceMatrix));
            glBindBuffer(GL_UNIFORM_BUFFER, 0);//释放绑定
            
            glm::mat4 model = glm::mat4(1.0f);
            
            for (unsigned int i = 0; i < objectPositions.size(); ++i) {
                model = glm::mat4(1.0f);
                model = glm::translate(model, objectPositions[i]);
                model = glm::scale(model, glm::vec3(0.25f, 0.25f, 0.25f));
                gBufferShader.setMat4fv("model", model);
                
                //            //法线矩阵
                model = glm::inverse(model);    //逆矩阵
                model = glm::transpose(model);  //转置矩阵
                gBufferShader.setMat4fv("normal", model);
                
                nanosuit.draw(gBufferShader);
            }
            
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
            
//
//            model = glm::mat4(1.0f);
//            model = glm::translate(model, lightPos);
//            model = glm::scale(model, glm::vec3(0.1f, 0.1f, 0.1f));
//            lightShader.setMat4fv("model", model);
//            box.draw(lightShader);

//            glBindVertexArray(0);

            //2、先渲染天空盒
//            glDepthFunc(GL_LEQUAL);
//            glCullFace(GL_FRONT);
//            cubeMap.use(GL_TEXTURE0);
//            skybox.draw(skyboxShader);
//            glCullFace(GL_BACK);
//            glDepthFunc(GL_LESS);
            
//            glClearColor(0.0, 0.0, 0.0, 1.0f);
//            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glDisable(GL_DEPTH_TEST);
            glDisable(GL_BLEND);
            
            lightingPassShader.use();
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, gPosition);

            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, gNormal);

            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, gAlbedoSpec);

            glm::vec3 position = camera.position();
            lightingPassShader.setVec3f("viewPos", position);

            for (unsigned int i = 0; i < lightPositions.size(); i++)
            {
                glm::vec3 lightColor = lightColors[i];
                lightingPassShader.setVec3f("lights[" + std::to_string(i) + "].Position", lightPositions[i]);
                lightingPassShader.setVec3f("lights[" + std::to_string(i) + "].Color", lightColor);
                
                
                GLfloat constant = 1.0;
                GLfloat linear = 0.22;
                GLfloat quadratic = 0.20;
                
                GLfloat lightMax = std::fmaxf(std::fmaxf(lightColor.r, lightColor.g), lightColor.b);
                GLfloat radius = (-linear + std::sqrtf(linear * linear - 4 * quadratic * (constant - (256.0 / 5.0) * lightMax))) / (2 * quadratic);
                
                lightingPassShader.setFloat("lights[" + std::to_string(i) + "].Linear", linear);
                lightingPassShader.setFloat("lights[" + std::to_string(i) + "].Quadratic", quadratic);
                lightingPassShader.setFloat("lights[" + std::to_string(i) + "].Radius", radius);
            }

            screen.draw(lightingPassShader);
            
            
            glEnable(GL_DEPTH_TEST);
            
            glBindFramebuffer(GL_READ_FRAMEBUFFER, gBuffer);
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
            glBlitFramebuffer(0, 0, SCR_WIDTH, SCR_HEIGHT, 0, 0, SCR_WIDTH, SCR_HEIGHT, GL_DEPTH_BUFFER_BIT, GL_NEAREST);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);

            //灯光
            for (int i = 0; i < lightPositions.size(); i++) {
                glm::vec3 position = lightPositions[i];
                glm::vec3 color = lightColors[i];

                model = glm::mat4(1.0f);
                model = glm::translate(model, position);
                model = glm::scale(model, glm::vec3(0.2f, 0.2f, 0.2f));

                lightShader.setVec3f("color", color);
                lightShader.setMat4fv("model", model);
                planet.draw(lightShader);
            }
            
            //检查有没有什么出发事件（键盘输入，鼠标移动等）
            glfwPollEvents();
            
            //切换双缓冲buffer
            glfwSwapBuffers(window);
        }
        
        //当渲染循环结束后我们需要正确释放所有资源
        glfwTerminate();
        return 0;
    }
    return 0;
}


