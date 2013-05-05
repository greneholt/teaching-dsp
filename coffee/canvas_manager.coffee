root = exports ? this

class root.CanvasManager
  constructor: (@canvas) ->
    @ctx = @canvas[0].getContext('2d')
    @renderables = []
    @interactives = []

    @mousedown = false

    @canvas.mousedown (e) =>
      [mouseX, mouseY] = this.getPosition(e)
      @mousedown = true
      for o in @interactives
        o.mousedown(mouseX, mouseY)

    @canvas.mouseup (e) =>
      [mouseX, mouseY] = this.getPosition(e)
      @mousedown = false
      for o in @interactives
        o.mouseup(mouseX, mouseY)

    # simulate mouseup on mouseout if the mouse was depressed (this fixes dragging glitches)
    @canvas.mouseout (e) =>
      [mouseX, mouseY] = this.getPosition(e)
      if @mousedown
        @mousedown = false
        for o in @interactives
          o.mouseup(mouseX, mouseY)

    @canvas.mousemove (e) =>
      [mouseX, mouseY] = this.getPosition(e)
      for o in @interactives
        o.mousemove(mouseX, mouseY)

  add: (object, interactive = false) ->
    @renderables.push(object)
    @interactives.push(object) if interactive

  remove: (object) ->
    remove object, @renderables
    remove object, @interactives

  render: ->
    width = @canvas[0].width
    height = @canvas[0].height
    @ctx.clearRect(0, 0, width, height)

    for renderable in @renderables
      renderable.render(@ctx, width, height)

  remove: (object, array) ->
    index = array.indexOf object
    array.splice index, 1 unless index == -1

  getPosition: (e) ->
    offset = @canvas.offset()
    mouseX = e.pageX - offset.left
    mouseY = e.pageY - offset.top
    return [mouseX, mouseY]