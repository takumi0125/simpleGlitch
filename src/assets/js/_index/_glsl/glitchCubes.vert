uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float animationValue;
uniform float animationCnt;
uniform float numInstances;
uniform float numCols;
uniform float numRows;
uniform float size;

attribute vec3 position;
attribute vec2 uv;
attribute vec3 normal;
attribute vec3 ramdomValues;
attribute float instanceIndex;

varying vec2 vUv;

#pragma glslify: rotateVec3 = require('../../_utils/glsl/rotateVec3.glsl')
#pragma glslify: PI = require('../../_utils/glsl/PI.glsl')

const vec3 AXIS_Z = vec3(0.0, 0.0, 1.0);

void main() {
  vec3 pos = position;
  float halfSize = size * 0.5;
  float halfPI = PI * 0.5;
  float offset = -((numCols * 2.0 - 1.0) * size) * 0.5;
  float rowIndex = floor(instanceIndex / numCols);

  pos = rotateVec3(pos, halfPI * animationCnt, AXIS_Z);
  pos.x += halfSize;
  pos.y += halfSize;
  pos = rotateVec3(pos, halfPI * animationValue, AXIS_Z);
  pos.x += offset + mod(instanceIndex, numCols) * size * 2.0 - size * animationCnt - ((mod(rowIndex, 2.0) - 0.5) * size);
  pos.z += offset + rowIndex * size * 2.0;

  vUv = uv;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
