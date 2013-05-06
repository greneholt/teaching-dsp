root = exports ? this

CanvasManager = root.CanvasManager
DragHandle = root.DragHandle
RangeIndicator = root.RangeIndicator
SpectrumDisplay = root.SpectrumDisplay

loadSound = (context, url, callback) ->
  request = new XMLHttpRequest()
  request.open('GET', url, true)
  request.responseType = 'arraybuffer'

  # Decode asynchronously
  request.onload = ->
    context.decodeAudioData request.response, callback

  request.send()

$(document).ready ->
  context = new webkitAudioContext()

  voiceBuffer = null
  noiseBuffer = null

  canvas = $('canvas')
  canvasManager = new CanvasManager(canvas)

  specDisplay = new SpectrumDisplay(canvasManager, 30, 0, 600, 300)

  handle1 = new DragHandle(canvasManager, 20, 350, 30, 30, "#005500", {minX: 15, maxX: 615})
  handle2 = new DragHandle(canvasManager, 80, 350, 30, 30, "#005500", {minX: 15, maxX: 615})

  bandPassInd = new RangeIndicator(canvasManager, 0, 300, "#005500", handle1, handle2)

  canvasManager.render()

  toLoad = 2

  onLoaded = ->
    toLoad--
    if toLoad == 0
      setup()

  loadSound context, 'atlys.mp3', (buffer) ->
    voiceBuffer = buffer
    onLoaded()

  loadSound context, 'noise.mp3', (buffer) ->
    noiseBuffer = buffer
    onLoaded()

  setup = ->
    pipeline = new AudioPipeline(context, noiseBuffer)

    specDisplay.analyser = pipeline.postAnalyser

    pipeline.setInterference 1500, 1, [900, 1100, 1300, 1500, 1700, 1900]

    pipeline.bandPass.set 2, 8, 1500, 1

    handle1.onMove = handle2.onMove = ->
      x1 = handle1.getMarkerX()
      x2 = handle2.getMarkerX()

      if x1 > x2
        [x1, x2] = [x2, x1]

      f1 = specDisplay.convertXtoF x1, context.sampleRate
      f2 = specDisplay.convertXtoF x2, context.sampleRate

      delta = f2 - f1
      freq = (f1 + f2)/2
      Q = freq / delta

      pipeline.bandPass.setFrequency freq
      pipeline.bandPass.setQ Q

    for freq in [900, 1100, 1300, 1500, 1700, 1900]
      pipeline.toneFilter.addFrequency freq

    playing = false
    intervalId = null

    $('#play-button').click ->
      if playing
        playing = false
        pipeline.stop()
        clearInterval intervalId
      else
        playing = true
        pipeline.play voiceBuffer

        intervalId = setInterval ->
          canvasManager.render()
        , 30