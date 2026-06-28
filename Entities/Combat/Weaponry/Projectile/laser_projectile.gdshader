shader_type spatial;

// By default, keep diffuse and specular calculations out of the main pass
render_mode diffuse_toon, specular_disabled; 

uniform vec4 emission_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float emission_energy : hint_range(0.0, 16.0) = 1.0;
uniform sampler2D albedo_texture : source_color;

void fragment() {
    // Apply your texture or color base
    vec4 tex = texture(albedo_texture, UV);
    ALBEDO = tex.rgb;
    
    // Inject the emission values directly into the fragment pass
    EMISSION = emission_color.rgb * emission_energy;
}

void light() {
    // Leaving this function entirely empty forces Godot to 
    // ignore all real-time scene lamps, suns, and directional lights.
}