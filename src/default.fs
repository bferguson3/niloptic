// Offset 9 lines from lightBlob
uniform vec4 ambience;
uniform mat4 liteTransform;

in vec3 Normal;
in vec3 FragmentPos;

uniform int useEmissive;

struct DirLight { 
    vec3 direction;
    vec4 ambient;
    vec4 diffuse;//vec3 specular;
};

const float minimumContrast = 0.001;

vec4 CalcDirLight(DirLight light, vec3 normal, vec4 baseColor)//vec3 viewDir, vec4 baseColor)
{   
    vec3 lightDir = normalize(-light.direction);
    float diff = max(dot(normal, lightDir), 0.0);//vec3 reflectDir//float spec
    vec4 ambient = light.ambient * baseColor;
    vec4 diffuse = light.diffuse * diff * baseColor;
    return (ambient + diffuse);
}

vec4 CalcPointLight(vec3 normal, vec4 baseColor, int num)
{
    vec3 lpos = (pointLightPositions[num] * liteTransform).xyz;
    vec3 lightDir = normalize(lpos - FragmentPos);
    float diff = max(dot(normal, lightDir), 0.0);
    //vec3 reflectDir
    //float spec
    float dist = length(lpos - FragmentPos);
    float constant = pointLightCLQ[num].x;
    float linear = pointLightCLQ[num].y;
    float quadratic = pointLightCLQ[num].z;
    float attenuation = 1.0 / (constant + linear * dist +
                                quadratic * (dist * dist));
    //if (attenuation < minimumContrast)
    //    { attenuation = 0.0; }
    //if (attenuation >  0.5) { attenuation = attenuation * 2.0; }
    //if (attenuation <= 0.5) { attenuation = attenuation / 2.0; }
    
    float abb = floor((attenuation+(1.0/8.0))*4.0) / 4.0;
    attenuation = abb;
    
    //if (attenuation <  0.01) { attenuation = 0.0; }
    //if (attenuation > 1.0) { attenuation = 1.0;}
    //vec4 diffuse = pointLightColors[num] * diff * baseColor;
    vec4 dif = pointLightColors[num] * baseColor; 
    dif *= attenuation;
    return dif;
}

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
{    
    //diffuse
    vec4 result = vec4(0.0, 0.0, 0.0, 1.0);
    vec3 norm = normalize(Normal); // The normal of the fragment will never change.
    vec4 baseColor = vec4(0.0, 0.0, 0.0, 1.0);
    if (useEmissive == 1) {
        baseColor = vec4(texture(lovrEmissiveTexture, uv)); 
    } else {
        baseColor = vec4(texture(image, uv)); 
    }
    // calculate light / other stuff on baseColor
    
    DirLight sun;
    sun.direction = sunDirection;
    sun.ambient = worldAmbience;
    sun.diffuse = sunColor;
    
    result += CalcDirLight(sun, norm, baseColor);

    
    for (int i = 0; i < pointLightCount; i ++)
    {
        result += CalcPointLight(norm, baseColor, i);
    }
    //vec4 objectColor = baseColor * vertexColor;

    return result;
}
