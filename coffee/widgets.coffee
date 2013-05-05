root = exports ? this

class root.DragHandle
  constructor: (canvasManager) ->
    @x = 0
    @y = 0
    @width = 20
    @height = 20
    @dragging = false
    canvasManager.add(this, true)

  render: (ctx, width, height) ->
    ctx.fillStyle = "#555555"
    ctx.fillRect(@x, @y, @width, @height)

  mousedown: (x, y) ->
    if x > @x and x < @x + @width and y > @y and y < @y + @height
      @mouseStartX = x
      @mouseStartY = y
      @dragging = true
      @startX = @x
      @startY = @y

  mouseup: (x, y) ->
    @dragging = false

  mousemove: (x, y) ->
    if @dragging
      @x = x - @mouseStartX + @startX
      @y = y - @mouseStartY + @startY