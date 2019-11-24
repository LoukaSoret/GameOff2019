shader_type spatial;

render_mode unshaded, cull_front;

uniform float thickness : hint_range(0,1) = 0.1;
uniform vec4 color : hint_color;

void vertex(){
    VERTEX *= 1.0+thickness;
}

void fragment(){
    ALBEDO = color.rgb;
}