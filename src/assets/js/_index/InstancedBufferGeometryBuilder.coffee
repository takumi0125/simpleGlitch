import PseudoInstancedBufferGeometry from './PseudoInstancedBufferGeometry'

export default class InstancedBufferGeometryBuilder
  constructor: (@_numInstances, @_baseBufferGeometry, @_isSupportedInstancedArray = true)->
    @_numPositions = @_baseBufferGeometry.attributes.position.array.length

    if @_isSupportedInstancedArray
      log 'ANGLE_instanced_arrays is supported'
      @_initTHREEIBGeometry()
    else
      log 'ANGLE_instanced_arrays is not supported'
      @_ibGeometry = new PseudoInstancedBufferGeometry @_numInstances, @_baseBufferGeometry



  # init THREE.InstancedBufferGeometry
  _initTHREEIBGeometry: ->
    @_ibGeometry = new THREE.InstancedBufferGeometry()
    @_ibGeometry.maxInstancedCount = @_numInstances

    instanceIndices = new THREE.InstancedBufferAttribute new Float32Array(@_numInstances), 1, 1
    randomValues = new THREE.InstancedBufferAttribute new Float32Array(@_numInstances * 3), 3, 1

    for i in [0...@_numInstances]
      randomValues.setXYZ i, @_getRandomValue(), @_getRandomValue(), @_getRandomValue()
      instanceIndices.setX i, i

    # attributes
    @_ibGeometry.addAttribute 'position', @_baseBufferGeometry.attributes.position.clone()
    @_ibGeometry.addAttribute 'uv', @_baseBufferGeometry.attributes.uv.clone()
    @_ibGeometry.addAttribute 'normal', @_baseBufferGeometry.attributes.normal.clone()
    @_ibGeometry.addAttribute 'instanceIndex', instanceIndices
    @_ibGeometry.addAttribute 'randomValues', randomValues

    # index
    @_ibGeometry.setIndex @_baseBufferGeometry.index.clone()

    @_ibGeometry.computeVertexNormals()

    return


  _getRandomValue: ->
    return (Math.random() + Math.random() + Math.random()) / 3


  getBefferGeometry: ->
    return @_ibGeometry


  setAttribute: (attributeName, data, itemSize, dataLabelX = 'x', dataLabelY = 'y', dataLabelZ = 'z', dataLabelW = 'w')->
    if @_isSupportedInstancedArray
      attribute = new THREE.InstancedBufferAttribute new Float32Array(@_numInstances * itemSize), itemSize, 1
      if itemSize is 1
        for i in [0...@_numInstances]
          attribute.setX i, data[i][dataLabelX]

      else if itemSize is 2
        for i in [0...@_numInstances]
          attribute.setXY i, data[i][dataLabelX], data[i][dataLabelY]

      else if itemSize is 3
        for i in [0...@_numInstances]
          attribute.setXYZ i, data[i][dataLabelX], data[i][dataLabelY], data[i][dataLabelZ]

      else if itemSize is 4
        for i in [0...@_numInstances]
          attribute.setXYZW i, data[i][dataLabelX], data[i][dataLabelY], data[i][dataLabelZ], data[i][dataLabelW]

    else
      attribute = new THREE.BufferAttribute(new Float32Array(@_numInstances * @_numPositions / 3 * itemSize), itemSize)
      if itemSize is 1
        for i in [0...@_numInstances]
          for j in [0...@_numPositions / 3]
            index = i * @_numPositions / 3 + j
            attribute.setX index, data[i][dataLabelX]

      else if itemSize is 2
        for i in [0...@_numInstances]
          for j in [0...@_numPositions / 3]
            index = i * @_numPositions / 3 + j
            attribute.setXY index, data[i][dataLabelX], data[i][dataLabelY]

      else if itemSize is 3
        for i in [0...@_numInstances]
          for j in [0...@_numPositions / 3]
            index = i * @_numPositions / 3 + j
            attribute.setXYZ index, data[i][dataLabelX], data[i][dataLabelY], data[i][dataLabelZ]

      else if itemSize is 4
        for i in [0...@_numInstances]
          for j in [0...@_numPositions / 3]
            index = i * @_numPositions / 3 + j
            attribute.setXYZW index, data[i][dataLabelX], data[i][dataLabelY], data[i][dataLabelZ], data[i][dataLabelW]

    @_ibGeometry.addAttribute attributeName, attribute
