#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    float dynamicIslandOffsetY = 0.46;
    float timeSquared = pow(uTime, 2.0);
    float timeCubed = pow(uTime, 3.0);

    // Normalizing UV Coordinates
    // UV coordinates are calculated by dividing the fragment coordinates by the view size.
    vec2 uv = fragCoord / uViewSize;

    // UV Stretch Calculation
    // Applying a transformation on UV coordinates depending on the time variable (uTime).
    vec2 uvTransformed = vec2(
    uv.x + ((uv.x - 0.5) * pow(uv.y, 6.0) * timeCubed * 0.1),
    uv.y * (uv.y * pow((1.0 - (timeSquared * 0.01)), 8.0)) + (1.0 - uv.y) * uv.y
    );
    uvTransformed = mix(uv, uvTransformed, smoothstep(1.1, 1.0, uTime));

    // Base Color Sampling
    // Sampling color from a texture using transformed UV coordinates.
    vec4 baseColor = texture(uTexture, uvTransformed);

    vec2 explosionOffset = vec2(0.0);
    float explosionBrightness = 0.0;

    // Explosion Effect Calculation
    // Adjusting UVs and brightness for a time-based explosion-like effect.
    if (uTime >= 1.0) {
        float adjustedTime = uTime - 1.0;
        uv -= 0.5;
        uv.x *= uViewSize.x / uViewSize.y;
        uv.x -= 0.1;

        vec2 uvExplosion = vec2(uv.x + 0.1, uv.y + dynamicIslandOffsetY);
        explosionBrightness = (adjustedTime * 0.16) / length(uvExplosion);
        explosionBrightness = smoothstep(0.09, 0.05, explosionBrightness) *
        smoothstep(0.04, 0.07, explosionBrightness) *
        (uv.y + 0.05);
        explosionOffset = vec2(-8.0 * explosionBrightness * uv.x,
        -4.0 * explosionBrightness * (uv.y - 0.4)) * 0.1;

        // Additional Burst
        // A second explosion effect is added with a minor delay for complexity in the animation.
        float explosionBrightness2 = ((adjustedTime - 0.085) * 0.14) / length(uvExplosion);
        explosionBrightness2 = smoothstep(0.09, 0.05, explosionBrightness2) *
        smoothstep(0.04, 0.07, explosionBrightness2) *
        (uv.y + 0.05);
        explosionOffset += vec2(-8.0 * explosionBrightness2 * uv.x,
        -4.0 * explosionBrightness2 * (uv.y - 0.4)) * -0.02;
    }

    // Adjusted UV and Color Brightness
    // Utilizing the calculated offset and brightness to affect the sampled color.
    vec2 uvFinal = uvTransformed + explosionOffset;
    baseColor = texture(uTexture, uvFinal);
    baseColor += explosionBrightness * 500.0 * smoothstep(1.05, 1.1, uTime);

    // Blur Calculation
    // Applying a radial blur effect to the rendered color, based on an evolving radius.
    const float PI = 6.28318530718;
    const float numDirections = 60.0;
    const float quality = 10.0;
    float blurRadius = timeSquared * 0.1 * pow(uv.y, 6.0) * 0.5;
    blurRadius *= smoothstep(1.3, 0.9, uTime);
    blurRadius += explosionBrightness * 0.05;

    for(float angle = 0.0; angle < PI; angle += PI / numDirections) {
        for(float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
            vec2 blurPos = uvFinal + vec2(cos(angle), sin(angle)) * blurRadius * i;
            baseColor += texture(uTexture, blurPos);
        }
    }
    baseColor /= quality * numDirections;

    // Glow Effects
    // Adding two distinct glow effects: one yellowish and one white, both influenced by uTime.
    uv.x -= 0.5;
    uv.x *= uViewSize.x / uViewSize.y;
    uv.y += dynamicIslandOffsetY;

    vec2 glowPos1 = vec2(uv.x * 0.65, uv.y - uTime + 0.5);
    float glowIntensity1 = smoothstep(0.0, 0.6, 0.1 / length(glowPos1) - dynamicIslandOffsetY) * 0.25;
    glowIntensity1 *= smoothstep(0.0, 0.3, uTime);
    baseColor += vec4(baseColor.r * glowIntensity1, baseColor.g * glowIntensity1, 0.0, 1.0);

    vec2 glowPos2 = vec2(uv.x * 0.4, uv.y - dynamicIslandOffsetY);
    float glowIntensity2 = smoothstep(0.0, 0.5, pow(1.0 - length(glowPos2), 28.0)) * 0.5;
    glowIntensity2 *= smoothstep(0.0, 1.0, timeSquared);
    glowIntensity2 *= smoothstep(1.13, 1.0, uTime);
    baseColor = vec4(baseColor.rgb * (1.0 - glowIntensity2), 1.0) + vec4(vec3(glowIntensity2), 1.0);

    // Final Color Output
    // Assigning the final calculated color to the output fragment color.
    FragColor = baseColor;
}
