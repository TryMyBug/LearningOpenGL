#version 330 core
out vec4 FragColor;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;
uniform sampler2D texture_normal1;
uniform sampler2D texture_height1;
uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D depthMap;

uniform float Shininess;
uniform float heightScale;

in VS_OUT
{
    vec2 TexCoords;         //输出，UV
    vec3 Normal;            //输出，法线
    vec3 FragPos;           //输出，片段位置
    
    vec3 TangentFragPos;
    vec3 TangentViewPos;
    vec3 TangentLightPos;
} fs_in;

uniform bool hasDisplacement;

vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir);

void main()
{
    vec2 texCoords = fs_in.TexCoords;
    
    vec3 viewDir = normalize(fs_in.TangentViewPos - fs_in.TangentFragPos);
    vec3 lightDir = normalize(fs_in.TangentLightPos - fs_in.TangentFragPos);
    
    
    if (hasDisplacement) {
        texCoords = ParallaxMapping(texCoords, viewDir);
//        if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0) {
//            discard;
//        }
    }
    vec3 color = vec3(texture(diffuseMap, -1.0 * texCoords));
    
    vec3 normal = vec3(texture(normalMap, texCoords));
    
    normal = normalize(normal * 2.0 - 1.0);
    
    //gamma纠正
//    float gamma = 2.0;
//    color = pow(color, vec3(gamma));

    vec3 ambient = 0.1 * color;
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * color;

    vec3 halfwayDir = normalize(lightDir + viewDir);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), Shininess);
    vec3 specular = spec * vec3(0.2);

    vec3 result = ambient + diffuse + specular;
//    result = vec3(texCoords, 0.0);
    //衰减
//    float distance1 = length(lightPos - fs_in.FragPos);
//    float attenuation = 1.0 / distance1;
//    if (blinn) {
//        attenuation = 1.0 / (distance1 * distance1);
//    }
//    result *= attenuation;
    
//    result = pow(result, vec3(1.0/gamma));
    FragColor = vec4(result, 1.0);
}
//vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
//{
//    float height = texture(depthMap, texCoords).r;
//    vec2 p = viewDir.xy * (height * heightScale);
//    return texCoords - p;
//}

//vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
//{
//    const float minLayers = 8;
//    const float maxLayers = 32;
//
//    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));
////    numLayers = 10;
//    float layerDepth = 1.0 / numLayers;
//    float currentLayerDepth = 0.0;
//
//    vec2 p = viewDir.xy * heightScale;
//    vec2 deltaTexCoords = p / numLayers;
//
//    vec2 currentTexCoords = texCoords;
//    float currentDepthMapValue = texture(depthMap, currentTexCoords).r;
//
//    while(currentLayerDepth < currentDepthMapValue) {
//        currentTexCoords -= deltaTexCoords;
//        currentDepthMapValue = texture(depthMap, currentTexCoords).r;
//        currentLayerDepth += layerDepth;
//    }
//
//    return currentTexCoords;
//}

vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{
    const float minLayers = 8;
    const float maxLayers = 32;
    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));

    float layerDepth = 1.0 / numLayers;

    float currentLayerDepth = 0.0;

    vec2 P = viewDir.xy / viewDir.z * heightScale;
    vec2 deltaTexCoords = P / numLayers;

    vec2  currentTexCoords     = texCoords;
    float currentDepthMapValue = texture(depthMap, currentTexCoords).r;

    while(currentLayerDepth < currentDepthMapValue)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = texture(depthMap, currentTexCoords).r;
        currentLayerDepth += layerDepth;
    }
    
    //遮蔽计算
    vec2 prevTexCoords = currentTexCoords + deltaTexCoords;
    
    float afterDepth = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = texture(depthMap, prevTexCoords).r - currentLayerDepth + layerDepth;
    
    float weight = afterDepth / (afterDepth - beforeDepth);
    vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
    return finalTexCoords;
}
