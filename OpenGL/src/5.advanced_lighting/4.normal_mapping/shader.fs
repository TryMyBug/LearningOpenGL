#version 330 core
out vec4 FragColor;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;
uniform sampler2D texture_normal1;
uniform sampler2D texture_height1;
uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform float Shininess;

in VS_OUT
{
    vec2 TexCoords;         //输出，UV
    vec3 Normal;            //输出，法线
    vec3 FragPos;           //输出，片段位置
    vec3 Tangent;
    
    vec3 TangentFragPos;
    vec3 TangentViewPos;
    vec3 TangentLightPos;
} fs_in;

uniform bool hasNormal2;

void main()
{
    vec3 normal = vec3(texture(normalMap, fs_in.TexCoords));
    
    if (hasNormal2) {
        normal = normalize(normal * 2.0 - 1.0);
    } else {
        normal = fs_in.Normal;
    }

    vec3 viewDir = normalize(fs_in.TangentViewPos - fs_in.TangentFragPos);
    vec3 lightDir = normalize(fs_in.TangentLightPos - fs_in.TangentFragPos);
    vec3 color = vec3(texture(diffuseMap, -1.0 * fs_in.TexCoords));
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
