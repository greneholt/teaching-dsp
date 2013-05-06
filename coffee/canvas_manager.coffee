root = exports ? this

class root.CanvasManager
  constructor: (@canvas) ->
    @ctx = @canvas[0].getContext('2d')
    @renderables = []
    @interactives = []

    @touches = {}
    @touchCount = 0

    # mouse events are the 0th touch
    @canvas.mousedown (e) =>
      this.grab 0, e

    $(window).mouseup (e) =>
      this.release 0, e

    # simulate release on mouseout if the mouse was depressed (this fixes dragging glitches)
    $(window).mouseout (e) =>
      if @touches[0]?
        this.release 0, e

    $(window).mousemove (e) =>
      this.drag 0, e

    @canvas.on 'touchstart', (e) =>
      stop = false
      for touch in e.originalEvent.changedTouches
        stop = true if this.grab touch.identifier, touch

      e.preventDefault() if stop

    $(window).on 'touchend', (e) =>
      e.preventDefault() if @touchCount > 0
      this.release touch.identifier, touch for touch in e.originalEvent.changedTouches

    $(window).on 'touchmove', (e) =>
      e.preventDefault() if @touchCount > 0
      this.drag touch.identifier, touch for touch in e.originalEvent.changedTouches

  grab: (id, e) ->
    [x, y] = this.getPosition(e)
    for o in @interactives
      if o.grab(x, y)
        @touches[id] = o
        @touchCount++
        return true

    return false

  release: (id, e) ->
    if @touches[id]?
      @touches[id].release()
      delete @touches[id]
      @touchCount--

  drag: (id, e) ->
    if @touches[id]?
      [x, y] = this.getPosition(e)
      @touches[id].drag x, y

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
    @ctx.clearRect 0, 0, width, height

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