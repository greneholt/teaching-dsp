root = exports ? this

CanvasManager = root.CanvasManager
DragHandle = root.DragHandle
RangeIndicator = root.RangeIndicator
LineIndicator = root.LineIndicator
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
  window.scrollTo 0, 1

  context = new webkitAudioContext()

  voiceBuffer = null
  noiseBuffer = null

  canvas = $('canvas')

  mgr = new CanvasManager(canvas)

  specDisplay = new SpectrumDisplay(25, 0, 675, 200)
  mgr.add specDisplay

  handle1 = new DragHandle(100, 250, 50, 50, "#3EA828", {minX: 0, maxX: 675})
  handle2 = new DragHandle(400, 250, 50, 50, "#3EA828", {minX: 0, maxX: 675})

  bandPassInd = new RangeIndicator(0, 200, "#3EA828", handle1, handle2)

  class NotchFilter
    constructor: (@filter) ->
      @handle = new DragHandle(400, 200, 50, 50, "#EB1A1A", {minX: 0, maxX: 675})
      @indicator = new LineIndicator(0, 200, "#EB1A1A", @handle)
      @handle.onMove = =>
        f = specDisplay.convertXtoF @handle.getMarkerX(), context.sampleRate
        f = Math.round(f/100)*100
        @filter.frequency.value = f

    addTo: (canvasManager) ->
      canvasManager.add @handle, true
      canvasManager.add @indicator

    removeFrom: (canvasManager) ->
      canvasManager.remove @handle
      canvasManager.remove @indicator

  mgr.render()

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

  calculateBandPass = ->
    x1 = handle1.getMarkerX()
    x2 = handle2.getMarkerX()

    if x1 > x2
      [x1, x2] = [x2, x1]

    f1 = specDisplay.convertXtoF x1, context.sampleRate
    f2 = specDisplay.convertXtoF x2, context.sampleRate

    delta = f2 - f1
    freq = (f1 + f2)/2
    Q = freq / delta

    $('#band-pass-info').text "Band-Pass Filter: #{Math.round(f1)}-#{Math.round(f2)} Hz, Bandwidth: #{Math.round(f2 - f1)} Hz"

    return [freq, Q]

  setup = ->
    pipeline = new AudioPipeline(context, noiseBuffer)

    specDisplay.analyser = pipeline.preAnalyser

    pipeline.setInterference 1500, 1, [900, 1100, 1300, 1500, 1700, 1900]

    handle1.onMove = handle2.onMove = ->
      [freq, Q] = calculateBandPass()
      pipeline.bandPass.setFrequency freq
      pipeline.bandPass.setQ Q

    # for freq in [900, 1100, 1300, 1500, 1700, 1900]
    #   pipeline.toneFilter.addFrequency freq

    playing = false
    intervalId = null

    $('#play-button').click (e) ->
      if playing
        playing = false
        $(e.target).text "Play"
        pipeline.stop()
        clearInterval intervalId
      else
        playing = true
        $(e.target).text "Stop"
        pipeline.play voiceBuffer

        intervalId = setInterval ->
          mgr.render()
        , 30

    $('.option').click (e) ->
      $(e.target).toggleClass 'enabled'

    $('#show-output-spectrum').click (e) ->
      if $(e.target).is('.enabled')
        specDisplay.analyser = pipeline.postAnalyser
      else
        specDisplay.analyser = pipeline.preAnalyser

    $('#enable-band-pass').click (e) ->
      if $(e.target).is('.enabled')
        mgr.add handle1, true
        mgr.add handle2, true
        mgr.add bandPassInd
        [freq, Q] = calculateBandPass()
        pipeline.bandPass.set 2, 8, freq, Q
        $('#band-pass-info').css 'visibility', 'visible'
      else
        mgr.remove handle1
        mgr.remove handle2
        mgr.remove bandPassInd
        pipeline.bandPass.clear()
        $('#band-pass-info').css 'visibility', 'hidden'

    notchFilters = []

    $('#add-notch-filter').click ->
      filter = pipeline.toneFilter.addFrequency 500
      notchFilter = new NotchFilter(filter)
      notchFilter.addTo mgr
      notchFilters.push notchFilter
