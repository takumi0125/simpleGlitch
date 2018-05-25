export default class VirtualInstancedBufferGeometry extends THREE.BufferGeometry
  constructor: (@_numInstances, @_baseBufferGeometry)->
    super()

    # init vertices and attributes
    @_vertices = []
    @_indices = []
    @_uvs = []
    @_instanceIndices = []
    @_randomValues = []

    baseBufferGeometryPositions = @_baseBufferGeometry.attributes.position.array
    numInstancePositions = baseBufferGeometryPositions.length

    baseBufferGeometryIndices = @_baseBufferGeometry.index.array
    numinstanceIndices = baseBufferGeometryIndices.length

    baseBufferGeometryUVs = @_baseBufferGeometry.attributes.uv.array

    for i in [0...@_numInstances]
      @_vertices
      randomValues = [
        @getRandomValue()
        @getRandomValue()
        @getRandomValue()
      ]

      for j in [0...numInstancePositions / 3]
        @_vertices.push baseBufferGeometryPositions[j * 3 + 0]
        @_vertices.push baseBufferGeometryPositions[j * 3 + 1]
        @_vertices.push baseBufferGeometryPositions[j * 3 + 2]
        @_uvs.push baseBufferGeometryUVs[j * 2 + 0]
        @_uvs.push baseBufferGeometryUVs[j * 2 + 1]
        @_randomValues.push randomValues[0]
        @_randomValues.push randomValues[1]
        @_randomValues.push randomValues[2]
        @_instanceIndices.push i

      for j in [0...numinstanceIndices]
        @_indices.push baseBufferGeometryIndices[j] + numInstancePositions / 3 * i


    # attributes
    @addAttribute 'position', new THREE.BufferAttribute(new Float32Array(@_vertices), 3)
    @addAttribute 'uv', new THREE.BufferAttribute(new Float32Array(@_uvs), 2)
    @addAttribute 'instanceIndex', new THREE.BufferAttribute(new Uint16Array(@_instanceIndices), 1)
    @addAttribute 'randomValues', new THREE.BufferAttribute(new Float32Array(@_randomValues), 3)
    @setIndex new THREE.BufferAttribute(new Uint16Array(@_indices), 1)

    # 配列としては使用しないので、メモリ解放
    delete @_vertices
    delete @_uvs
    delete @_indices
    delete @_instanceIndices
    delete @_randomValues

    @computeVertexNormals()



  getRandomValue: ->
    return (Math.random() + Math.random() + Math.random()) / 3
