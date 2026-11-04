
shader_type canvas_item;

uniform float altura_recorte : hint_range(0.0, 0.3) = 0.075;
uniform float irregularidad : hint_range(0.0, 0.05) = 0.012;

void fragment() {
    vec4 papel = texture(TEXTURE, UV);

    // Crear un borde irregular, como papel recortado
    float borde = altura_recorte
        + sin(UV.x * 35.0) * irregularidad
        + sin(UV.x * 83.0) * irregularidad * 0.35
        + sin(UV.x * 157.0) * irregularidad * 0.15;

    // Recortar la parte superior sin oscurecerla
    if (UV.y < borde) {
        discard;
    }

    COLOR = papel;
}
