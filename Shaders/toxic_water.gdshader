shader_type spatial;
uniform sampler2D tex;
uniform sampler2D normalmap;
float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}
void vertex() {
	VERTEX.y += sin(TIME + VERTEX.x * 20.0) * 0.2;
	VERTEX.z += sin(TIME + VERTEX.y * 20.0) * 0.2;
}


void fragment() {
	vec3 color;
	color = texture(tex, UV).rgb;
	METALLIC = 1.0;
	color.b += 0.1;

	ALBEDO = color;
	ALPHA = 0.9;
	ROUGHNESS = 0.8;
	NORMAL_MAP = texture(normalmap, UV).rgb;
}