uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float animationValue1;
uniform float animationValue2;

attribute vec3 position;
attribute vec2 uv;

varying vec2 vUv;

void main() {
  vec3 pos = position;
  pos.x *= (1.0 + 1.0 * animationValue1);
  pos.y *= (1.0 - 0.5 * animationValue1);
  pos.z *= (1.0 - 0.5 * animationValue1);

  vUv = uv;
  vUv *= (1.0 + 1.0 * animationValue2);


  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
