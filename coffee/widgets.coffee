root = exports ? this

class root.DragHandle
  constructor: (@x, @y, @width, @height, @color, @options = {}) ->
    @onMove = null

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
    ctx.strokeStyle = "#333333"
    ctx.stroke()
    ctx.restore()

  grab: (x, y) ->
    if x > @x and x < @x + @width and y > @y and y < @y + @height
      @dragStartX = x
      @startX = @x
      return true
    else
      return false

  release: ->

  getMarkerX: ->
    @x + @width/2

  drag: (x, y) ->
    @x = x - @dragStartX + @startX
    @x = @options.minX if @options.minX? and @x < @options.minX
    @x = @options.maxX if @options.maxX? and @x > @options.maxX

    @onMove() if @onMove?

class root.RangeIndicator
  constructor: (@y, @height, @color, @handle1, @handle2) ->

  render: (ctx, width, heigh) ->
    ctx.fillStyle = @color
    ctx.globalAlpha = 0.5
    x1 = @handle1.getMarkerX()
    x2 = @handle2.getMarkerX()

    if x1 > x2
      [x1, x2] = [x2, x1]

    ctx.fillRect x1, @y, x2 - x1, @height
    ctx.globalAlpha = 1 # reset alpha

class root.LineIndicator
  constructor: (@y, @height, @color, @handle) ->

  render: (ctx, width, height) ->
    ctx.fillStyle = @color
    ctx.globalAlpha = 0.5
    x = @handle.getMarkerX()

    ctx.fillRect x - 1, @y, 3, @height
    ctx.globalAlpha = 1 # reset alpha

class root.SpectrumDisplay
  constructor: (@x, @y, @width, @height) ->
    @analyser = null

  render: (ctx, width, height) ->
    ctx.strokeStyle = "#aaaaaa"
    ctx.lineWidth = 1
    ctx.strokeRect @x, @y, @width, @height
    if @analyser?

      freqByteData = new Uint8Array(@analyser.frequencyBinCount)
      @analyser.getByteFrequencyData freqByteData

      ctx.fillStyle = "#47ACF5"
      for i in [0...@width]
        ctx.fillRect @x + i, @y + @height, 1, -(freqByteData[i] / 255) * @height

  convertXtoF: (x, Fs) ->
    return null unless @analyser?

    (x - @x) / @analyser.frequencyBinCount * Fs / 2