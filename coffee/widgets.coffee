root = exports ? this

class root.DragHandle
  constructor: (canvasManager, @x, @y, @width, @height, @options = {}) ->
    @dragging = false
    canvasManager.add(this, true)

  render: (ctx, width, height) ->
    ctx.save()
    ctx.translate @x, @y
    ctx.fillStyle = "#777777"
    ctx.beginPath()
    ctx.moveTo 0, @height
    ctx.lineTo @width, @height
    ctx.lineTo @width/2, 0
    ctx.closePath()
    ctx.fill()
    ctx.restore()

  grab: (x, y) ->
    if x > @x and x < @x + @width and y > @y and y < @y + @height
      @mouseStartX = x
      @mouseStartY = y
      @dragging = true
      @startX = @x
      @startY = @y

      return true

  release: ->
    @dragging = false

  drag: (x, y) ->
    if @dragging
      @x = x - @mouseStartX + @startX unless @options.constrainX
      @y = y - @mouseStartY + @startY unless @options.constrainY

class root.SpectrumDisplay
  constructor: (canvasManager, @x, @y, @width, @height) ->
    canvasManager.add(this)
    @analyser = null

  render: (ctx, width, height) ->
    ctx.strokeStyle = "#444444"
    ctx.lineWidth = 1
    ctx.strokeRect(@x, @y, @width, @height)
    if @analyser?

      freqByteData = new Uint8Array(@analyser.frequencyBinCount)
      @analyser.getByteFrequencyData freqByteData

      ctx.fillStyle = "#47ACF5"
      for i in [0...@width]
        ctx.fillRect @x + i, @y + @height, 1, -freqByteData[i]