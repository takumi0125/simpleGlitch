window.glitch = window.glitch || {}

import GlitchCubes from './GlitchCubes'

export default class Index
  constructor: ->
    @initWebGL()
    @cubes.init().then =>
      @animationId = null
      @startTime = new Date().getTime()
      @cubes.start()
      @setCameraPosTimer()
      @update()


  initWebGL: ->
    @container = document.querySelector '.js-mainCanvas'
    @renderer = new THREE.WebGLRenderer
      canvas: @container.querySelector 'canvas'
      alpha: true
      # antialias: true

    @scene = new THREE.Scene()

    @width = @container.offsetWidth
    @height = @container.offsetHeight

    @camera = new THREE.OrthographicCamera -@width * 0.5, @width * 0.5, @height * 0.5, -@height * 0.5, 1, 10000
    @setCameraPos()

    @camera.lookAt 0, 0, 0

    isSupportedInstancedArray = @renderer.extensions.get('ANGLE_instanced_arrays')

    @cubes = new GlitchCubes(
      [
        { imgPath: '/assets/img/img1.png' }
        { imgPath: '/assets/img/img2.png' }
      ]
      120
      120
      120
      20
      20
      isSupportedInstancedArray
    )
    @scene.add @cubes.mesh

    window.addEventListener 'resize', @resize

    @resize()


  setCameraPosTimer: =>
    setInterval (=> @setCameraPos()), 4000
    return

  setCameraPos: =>
    rad = Math.PI * 2 * Math.random()
    @camera.position.x = 200 * Math.cos(rad)
    @camera.position.y = 400
    @camera.position.z = 1000 * Math.sin(rad)
    @camera.lookAt 0, 0, 0
    return


  resize: (e = null)=>
    @width = @container.offsetWidth
    @height = @container.offsetHeight
    @renderer.setSize @width, @height
    @camera.top = @height * 0.5
    @camera.bottom = -@height * 0.5
    @camera.left = -@width * 0.5
    @camera.right = @width * 0.5
    @camera.updateProjectionMatrix()



  update: =>
    @animationId = requestAnimationFrame @update

    time = new Date().getTime() - @startTime
    @cubes.update time

    @renderer.render @scene, @camera
