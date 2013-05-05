root = exports ? this

class root.CanvasManager
  constructor: (@canvas) ->
    @ctx = @canvas[0].getContext('2d')
    @renderables = []
    @interactives = []

    @dragging = false

    @canvas.mousedown (e) =>
      this.grab e

    @canvas.mouseup (e) =>
      this.release e

    # simulate mouseup on mouseout if the mouse was depressed (this fixes dragging glitches)
    @canvas.mouseout (e) =>
      this.release e

    @canvas.mousemove (e) =>
      this.drag e

    @canvas.on 'touchstart', (e) =>
      if this.grab e.originalEvent.touches[0]
        e.preventDefault()

    @canvas.on 'touchend', (e) =>
      e.preventDefault() if @dragging
      this.release e.originalEvent.touches[0]

    @canvas.on 'touchmove', (e) =>
      e.preventDefault() if @dragging
      this.drag e.originalEvent.touches[0]

  grab: (e) ->
    [mouseX, mouseY] = this.getPosition(e)
    for o in @interactives
      if o.grab(mouseX, mouseY)
        @dragging = true
    return @dragging

  release: (e) ->
    if @dragging
      @dragging = false
      for o in @interactives
        o.release()

  drag: (e) ->
    if @dragging
      [mouseX, mouseY] = this.getPosition(e)
      for o in @interactives
        o.drag(mouseX, mouseY)

      this.render()

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