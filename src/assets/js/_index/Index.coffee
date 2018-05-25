window.glitch = window.glitch || {}

import GlitchPlane from './GlitchPlane'

export default class Index
  constructor: ->
    @initWebGL()
    @plane.init().then =>
      @animationId = null
      @startTime = new Date().getTime()
      @plane.start()
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

    @plane = new GlitchPlane(
      [
        { imgPath: '/assets/img/img1.png' }
        { imgPath: '/assets/img/img2.png' }
      ]
      40
      40
    )
    @scene.add @plane.mesh

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

    intersects = @raycaster.intersectObjects [@plane.mesh]

    if intersects.length > 0
      if !@isHovered
        @isHovered = true
        @plane.doGlitch()
    else
      if @isHovered
        @isHovered = false
        @plane.cancelGlitch()


  resize: (e = null)=>
    @width = @container.offsetWidth
    @height = @container.offsetHeight
    @renderer.setSize @width, @height
    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()



  update: =>
    @animationId = requestAnimationFrame @update

    time = new Date().getTime() - @startTime
    @plane.update time

    @renderer.render @scene, @camera
