shader_type spatial;

uniform vec4 color1 : source_color = vec4(0.592, 0.475, 0.820, 1.0);
uniform vec4 color2 : source_color = vec4(0.110, 0.082, 0.161, 1.0);
uniform float size = 32.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv_scaled = UV * size;
	int x = int(floor(uv_scaled.x));
	int y = int(floor(uv_scaled.y));
	
	bool is_even = (x + y) % 2 == 0;
	
	ALBEDO = is_even ? color1.rgb : color2.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
