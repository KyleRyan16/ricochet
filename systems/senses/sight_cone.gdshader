shader_type spatial;
render_mode unshaded;

// for circles
uniform float amplitude: hint_range(0, 2, 0.01) = 2.0;
uniform float frequency: hint_range(0, 15, 0.01) = 12.69;
uniform float rippleRate : hint_range(0.5, 150.0, 0.1) = 9.2;

uniform vec3 wave_color : source_color;


// for wave
uniform float waveAmplitude = 0.1;
uniform float waveFrequency = 4.0;

// other
uniform sampler2D noise;
uniform float noise_size = 1;

vec2 wave(vec2 uv, float time) {
    return vec2(
        uv.x + sin(uv.y * waveFrequency * 5.0 + time) * waveAmplitude,
        uv.y + sin(uv.x * waveFrequency + time) * waveAmplitude
    );
}

void fragment() {
	vec2 uv = vec2(UV.x - 0.5, UV.y);
	vec2 wave_uv = wave(uv, TIME);
	vec4 ns = texture(noise, uv);
	

	float dist = length(uv) - 0.2;
	float ripple = sin(dist * -frequency + rippleRate * TIME) * amplitude / dist;

	vec4 color;
	color.rgb = wave_color;
	color.a = min(ripple, 1);

   	ALBEDO = max(color.rgb, vec3(0.01, 0.01, 0.01));
	ALPHA = max(color.a, 0.3);
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
