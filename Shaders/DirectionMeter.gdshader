shader_type spatial;
uniform vec3 direction;
void fragment() {
	// Place fragment code here.

}
void vertex() {
	VERTEX.x += cos(direction.y) * 2.0;
	VERTEX.z += sin(direction.y) * 2.0;
	VERTEX.y += 1.0 + cos(direction.z) * 2.0;

}