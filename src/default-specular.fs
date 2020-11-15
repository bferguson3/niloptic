uniform vec4 ambience;

in vec3 Normal;
in vec3 FragmentPos;

uniform vec3 lightPos;
uniform vec4 liteColor;


uniform vec4 viewPos;
uniform float specularStrength;
uniform float metallic;

uniform vec3 pOffset;
uniform mat4 liteTransform;
// Blob values:
//uniform int lightCount;
//uniform vec4 pointLightPos[16];
//uniform vec4 lightColors[16];
//uniform float lightRanges[16];

//vec3 lightDirs[16];
//float diffs[16];
//vec4 diffuses[16];
//vec3 reflectDirs[16];
//float specs[16];
//vec4 speculars[16];
//float dists[16];
//vec4 specular;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
{    
    //diffuse
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize((viewPos * liteTransform).xyz - FragmentPos);
    //vec3 viewDir = normalize((viewPos).xyz - FragmentPos);
    vec3 temp = (liteTransform * pointLightPositions[0]).xyz;
    vec3 lightDir = normalize(temp - FragmentPos);
    vec4 diffuse = vec4(0.0, 0.0, 0.0, 0.0);//diff * liteColor;
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
    vec4 specular = specularStrength * spec * liteColor;
    

    vec4 baseColor = vec4(texture(image, uv));
    //vec4 objectColor = baseColor * vertexColor;

    return baseColor;
}