#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform sampler2D iChannel0;
uniform float pixel;

out vec4 fragColor;

void main()
{
    vec2 fragCoord = FlutterFragCoord().xy;
    // Calculate texture coordinates
    vec2 uv = fragCoord / iResolution.xy;

    // Calculate pixel size
    vec2 pixel_size = pixel / iResolution.xy;
    const float edge = 2.0;

    vec4 total = vec4(0.0);

    for (float i = -edge; i <= edge; i += 2.0) {
        for (float j = -edge; j <= edge; j += 2.0) {
            total += (texture(iChannel0, uv + pixel_size * vec2(i, j)) * 0.1);
        }
    }

    fragColor = total;
}