shader_type spatial;
render_mode unshaded, cull_disabled; // 取消光照计算，接近二维效果

uniform sampler2D base_texture : source_color;
uniform vec4 line_color : source_color = vec4(0.1, 0.1, 0.1, 1.0); // 手绘线条颜色
uniform float line_intensity : hint_range(0, 2) = 1.2; // 线条强度
uniform vec4 tint_color : source_color = vec4(0.8, 0.9, 0.8, 1.0); // 罗小黑标志性浅绿色

void fragment() {
    vec2 uv = UV * 10.0; // 纹理重复次数，根据场景大小调整
    vec4 tex_color = texture(base_texture, uv);
    
    // 提取线条（通过亮度判断）
    float line = step(0.9, tex_color.r) * line_intensity;
    
    // 平涂色块+线条+色调
    vec3 color = tint_color.rgb * (1.0 - line * 0.3);
    color = mix(color, line_color.rgb, line);
    
    // 水墨晕染效果（边缘渐变）
    vec2 edge = smoothstep(0.01, 0.05, abs(0.5 - fract(uv * 5.0)));
    color *= mix(1.0, 0.8, edge.x * edge.y);
    
    ALBEDO = color;
    ALPHA = 1.0;
}