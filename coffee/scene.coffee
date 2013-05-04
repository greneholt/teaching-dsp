class Scene
  constructor: (@canvas) ->
    @ctx = @canvas[0].getContext('2d')
    @renderables = []

  addRenderable: (renderable) ->
    @renderables.push(renderable)

  removeRenderable: (renderable) ->
    index = @renderables.indexOf renderable

    unless index == -1
      @renderables.splice index, 1

  render: ->
    width = @canvas[0].width
    height = @canvas[0].height
    @ctx.clearRect(0, 0, width, height)

    for renderable in @renderables
      renderable.render(@ctx, width, height)

root = exports ? this

root.Scene = Scene