root = exports ? this

class root.DragHandle
  constructor: (canvasManager, @x, @y, @width, @height, @color, @options = {}) ->
    canvasManager.add(this, true)

  render: (ctx, width, height) ->
    ctx.save()
    ctx.translate @x, @y
    ctx.fillStyle = @color
    ctx.beginPath()
    ctx.moveTo 0, @height
    ctx.lineTo @width, @height
    ctx.lineTo @width/2, 0
    ctx.closePath()
    ctx.fill()
    ctx.restore()

  grab: (x, y) ->
    if x > @x and x < @x + @width and y > @y and y < @y + @height
      @dragStartX = x
      @dragStartY = y
      @startX = @x
      @startY = @y
      return true
    else
      return false

  release: ->

  drag: (x, y) ->
    @x = x - @dragStartX + @startX
    @x = @options.minX if @options.minX? and @x < @options.minX
    @x = @options.maxX if @options.maxX? and @x > @options.maxX

    @y = y - @dragStartY + @startY
    @y = @options.minY if @options.minY? and @y < @options.minY
    @y = @options.maxY if @options.maxY? and @y > @options.maxY

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