window.glitch = window.glitch || {}

import GlitchCube from './GlitchCube'

export default class Index
  constructor: ->
    @initWebGL()
    @cube.init().then =>
      @animationId = null
      @startTime = new Date().getTime()
      @cube.start()
      @update()


  initWebGL: ->
    @container = document.querySelector '.js-mainCanvas'
    @renderer = new THREE.WebGLRenderer
      canvas: @container.querySelector 'canvas'
      alpha: true
      # antialias: true

    @devicePixelRatio = window.devicePixelRatio || 1
    @devicePixelRatio = Math.min 2, @devicePixelRatio
    window.glitch.devicePixelRatio = @devicePixelRatio
    @renderer.setPixelRatio @devicePixelRatio

    @scene = new THREE.Scene()

    @width = @container.offsetWidth
    @height = @container.offsetHeight

    @camera = new THREE.PerspectiveCamera 45, @width / @height, 1, 1000
    @camera.position.z = 100

    @cube = new GlitchCube(
      [
        { imgPath: '/assets/img/img1.png' }
        { imgPath: '/assets/img/img2.png' }
      ]
      40
      40
      40
    )
    @scene.add @cube.mesh

    @raycaster = new THREE.Raycaster()
    @mouse = { x: 0, y: 0 }

    window.addEventListener 'resize', @resize
    window.addEventListener 'mousemove', @mousemove

    @resize()


  mousemove: (e)=>
    x = e.clientX
    y = e.clientY

    @mouse.x = (x / @width) * 2 - 1
    @mouse.y = -(y / @height) * 2 + 1

    @raycaster.setFromCamera @mouse, @camera

    intersects = @raycaster.intersectObjects [@cube.mesh]

    if intersects.length > 0
      if !@isHovered
        @isHovered = true
        @cube.doGlitch()
    else
      if @isHovered
        @isHovered = false
        # @cube.cancelGlitch()


  resize: (e = null)=>
    @width = @container.offsetWidth
    @height = @container.offsetHeight
    @renderer.setSize @width, @height
    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()



  update: =>
    @animationId = requestAnimationFrame @update

    time = new Date().getTime() - @startTime
    @cube.update time

    @renderer.render @scene, @camera
