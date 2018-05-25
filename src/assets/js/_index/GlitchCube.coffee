window.glitch = window.glitch || {}

import map from '../_utils/math/map'

export default class GlitchCube
  _BLOCK_NOISE_TEXTURE_SIZE = 256

  constructor: (@data, @width = 10, @height = 10, @depth = 10)->
    @textures = []
    @textureIndex = 0
    @numTextures = @data.length
    @numTotalImgs = 0
    @numLoadedImgs = 0
    @animationValueIndex = 0

    @blockNoiseCanvas = document.createElement('canvas')
    @blockNoiseCanvas.width = _BLOCK_NOISE_TEXTURE_SIZE
    @blockNoiseCanvas.height = _BLOCK_NOISE_TEXTURE_SIZE
    @blockNoiseCtx = @blockNoiseCanvas.getContext '2d'
    @blockNoiseTexture = new THREE.Texture @blockNoiseCanvas
    @blockNoiseTexture.minFilter = THREE.NearestFilter
    @blockNoiseTexture.magFilter = THREE.NearestFilter
    @blockNoiseTexture.wrapS = THREE.MirroredRepeatWrapping
    @blockNoiseTexture.wrapT = THREE.MirroredRepeatWrapping
    @blockNoiseCanvas.style.zIndex = 1000
    @blockNoiseCanvas.style.position = 'fixed'
    @blockNoiseCanvas.style.top = '0px'
    @blockNoiseCanvas.style.left = '0px'

    geometry = new THREE.BoxGeometry @width, @height, @depth
    @material = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/glitchCube.vert')
      fragmentShader: require('./_glsl/glitchCube.frag')
      depthTest: false
      depthWrite: false
      transparent: true
      side: THREE.DoubleSide
      blending: THREE.AdditiveBlending
      uniforms:
        time: { type: '1f', value: 0 }
        timeOffset: { type: '1f', value: Math.random() * 1000.0 }
        img1: { type: 't', value: null }
        img2: { type: 't', value: null }
        resolution: { type: '2f', value: new THREE.Vector2(@width, @height) }
        blockNoiseTexture: { type: 't', value: @blockNoiseTexture }
        randomValues: { type: '3f', value: new THREE.Vector3() }
        glitchValue: { type: '1f', value: 0 }
        imgRatio: { type: '1f', value: 0 }
        animationValue1: { type: '1f', value: 0 }
        animationValue2: { type: '1f', value: 0 }

    @mesh = new THREE.Mesh geometry, @material

    @swapTexturesTimeline = null
    @glitchTimer = null



  doGlitch: ->
    @clearGlitchTimer()
    @swapTextures()


  cancelGlitch: ->
    @swapTexturesTimeline?.kill()
    @material.uniforms.glitchValue.value = 0
    @material.uniforms.imgRatio.value = 0
    @setGlichTimer()


  updateBlockNoise: ->
    @blockNoiseCtx.clearRect 0, 0, _BLOCK_NOISE_TEXTURE_SIZE, _BLOCK_NOISE_TEXTURE_SIZE

    for i in [0...4 + Math.floor(Math.random() * 4)]
      c1 = Math.random()
      c2 = Math.random()
      offsetX = Math.random() * _BLOCK_NOISE_TEXTURE_SIZE
      offsetY = Math.random() * _BLOCK_NOISE_TEXTURE_SIZE
      w = (0.1 + Math.random() * 0.1) * _BLOCK_NOISE_TEXTURE_SIZE
      h = (0.04 + Math.random() * 0.04) * _BLOCK_NOISE_TEXTURE_SIZE

      @blockNoiseCtx.fillStyle = "rgba(#{Math.floor(c1 * 256)}, #{Math.floor(c2 * 256)}, 0, 1)"
      @blockNoiseCtx.fillRect offsetX - w / 2, offsetY - h / 2, w, h


    @blockNoiseTexture.needsUpdate = true
    @material.needsUpdate = true
    return



  swapTextures: ->
    @swapTexturesTimeline?.kill()

    @material.uniforms.glitchValue.value = 1
    animationValueKey = "animationValue#{(@animationValueIndex++ % 2 + 1).toString()}";

    @swapTexturesTimeline = new TimelineMax()
    .to @material.uniforms.imgRatio, 0.2, { value: 1, ease: Expo.easeInOut }, 0.2
    .to @material.uniforms[animationValueKey], 0.4, { value: 1, ease: Expo.easeOut }, 0
    .add (=> @updateBlockNoise()), 0.05
    .add (=> @updateBlockNoise()), 0.1
    .add (=> @updateBlockNoise()), 0.15
    .add (=> @updateBlockNoise()), 0.2
    .add (=> @updateBlockNoise()), 0.25
    .add (=> @updateBlockNoise()), 0.3
    .add (=> @updateBlockNoise()), 0.35
    .add (=>
      @material.uniforms.glitchValue.value = 0
      @material.uniforms.imgRatio.value = 0
      @setImgs()
      @setGlichTimer()
    ), 0.4
    .to @material.uniforms[animationValueKey], 0.4, { value: 0, ease: Expo.easeInOut }, 0.3
    return


  setGlichTimer: ->
    @clearGlitchTimer()
    @glitchTimer = setTimeout (=> @swapTextures()), 5000


  clearGlitchTimer: ->
    if @glitchTimer? then clearTimeout @glitchTimer
    @glitchTimer = null
    return



  init: ->
    promises = []
    for d in @data
      promises.push @loadTexture d.imgPath

    return Promise.all(promises).then =>
      @setImgs()
      return true



  setImgs: ->
    @material.uniforms.img1.value = @textures[@textureIndex]
    @textureIndex = ++@textureIndex % @numTextures
    @material.uniforms.img2.value = @textures[@textureIndex]
    @material.needsUpdate = true
    return


  loadTexture: (imgPath)->
    @numTotalImgs++
    loader = new THREE.TextureLoader()
    return new Promise (resolve)=>
      texture = loader.load imgPath, =>
        @numLoadedImgs++
        resolve()

      texture.wrapS = THREE.RepeatWrapping
      texture.wrapT = THREE.RepeatWrapping
      texture.minFilter = THREE.LinearFilter
      texture.magFilter = THREE.LinearFilter
      texture.wrapS = THREE.MirroredRepeatWrapping
      texture.wrapT = THREE.MirroredRepeatWrapping
      @textures.push texture


  update: (time)->
    @mesh.rotation.x += 0.006
    @mesh.rotation.y += 0.01
    @mesh.rotation.z += 0.004
    @material.uniforms.time.value = time
    @material.uniforms.randomValues.value.set(
      map Math.random(), 0, 1, -1, 1
      map Math.random(), 0, 1, -1, 1
      map Math.random(), 0, 1, -1, 1
    )
    @material.needsUpdate = true
    return


  start: ->
    @setGlichTimer()
    return


  pause: ->
    @clearGlitchTimer()
    return
