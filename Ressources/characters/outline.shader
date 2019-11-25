shader_type spatial;

render_mode unshaded, cull_front;

void vertex(){
    VERTEX.xz *= 1.1 ;
    if(VERTEX.y>1.1)
        VERTEX.y *= 1.025;
}

void fragment(){
    ALBEDO = vec3(0);
}