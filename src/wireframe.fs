uniform sampler2D wf;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    return graphicsColor * texture(wf, uv);
}