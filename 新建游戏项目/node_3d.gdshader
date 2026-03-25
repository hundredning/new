shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength: hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);
    
    float blur = blur_strength * 0.02;
    
    color += texture(SCREEN_TEXTURE, uv + vec2(-blur, -blur));
    color += texture(SCREEN_TEXTURE, uv + vec2(0.0, -blur));
    color += texture(SCREEN_TEXTURE, uv + vec2(blur, -blur));
    color += texture(SCREEN_TEXTURE, uv + vec2(-blur, 0.0));
    color += texture(SCREEN_TEXTURE, uv + vec2(0.0, 0.0));
    color += texture(SCREEN_TEXTURE, uv + vec2(blur, 0.0));
    color += texture(SCREEN_TEXTURE, uv + vec2(-blur, blur));
    color += texture(SCREEN_TEXTURE, uv + vec2(0.0, blur));
    color += texture(SCREEN_TEXTURE, uv + vec2(blur, blur));
    
    color /= 9.0;
    
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 ink_color = vec3(gray);
    
    // 【关键修改 1】把对比度降下来，让黑色不那么死，过渡更柔和
    // 原来的是 smoothstep(0.3, 0.7, ...)，现在改成 0.1 到 0.9
    ink_color = smoothstep(0.2, 0.8, ink_color);
    
    // 【关键修改 2】整体提亮水墨效果，让黑的地方淡一点
    ink_color = ink_color * 0.8 + 0.2; 
    
    COLOR.rgb = mix(texture(SCREEN_TEXTURE, uv).rgb, ink_color, blur_strength);
    COLOR.a = 1.0;
}