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

  window.AudioContext = window.AudioContext || window.webkitAudioContext;
  context = new AudioContext();

  voiceBuffer = null
  noiseBuffer = null

  canvas = $('canvas')

  mgr = new CanvasManager(canvas)

  specDisplay = new SpectrumDisplay(context, 25, 1, 675, 200)
  mgr.add specDisplay

  handle1 = new DragHandle(100, 250, 50, 50, "#3EA828", {minX: 0, maxX: 675})
  handle2 = new DragHandle(400, 250, 50, 50, "#3EA828", {minX: 0, maxX: 675})

  bandPassInd = new RangeIndicator(1, 200, "#3EA828", handle1, handle2)

  class NotchFilter
    constructor: (@filter) ->
      @handle = new DragHandle(400, 200, 50, 50, "#EB1A1A", {minX: 0, maxX: 675})
      @indicator = new LineIndicator(1, 200, "#EB1A1A", @handle)

      this.updateFilter()

      @onMove = null
      @handle.onMove = =>
        this.updateFilter()
        @onMove() if @onMove?

    addTo: (canvasManager) ->
      canvasManager.add @handle, true
      canvasManager.add @indicator

    removeFrom: (canvasManager) ->
      canvasManager.remove @handle
      canvasManager.remove @indicator

    updateFilter: =>
      f = specDisplay.convertXtoF @handle.getMarkerX()
      f = Math.round(f/100)*100 # round to nearest 100 Hz
      @filter.frequency.value = f

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

    f1 = specDisplay.convertXtoF x1
    f2 = specDisplay.convertXtoF x2

    delta = f2 - f1
    freq = (f1 + f2)/2
    Q = freq / delta

    $('#band-pass-info').text "Band-Pass Filter: #{Math.round(f1)}-#{Math.round(f2)} Hz, Bandwidth: #{Math.round(f2 - f1)} Hz"

    return [freq, Q]

  setup = ->
    pipeline = new AudioPipeline(context, noiseBuffer)

    specDisplay.analyser = pipeline.preAnalyser

    pipeline.setInterference 1500, 0.7, [900, 1100, 1300, 1500, 1700, 1900]

    handle1.onMove = handle2.onMove = ->
      [freq, Q] = calculateBandPass()
      pipeline.bandPass.setFrequency freq
      pipeline.bandPass.setQ Q

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

    volumeSlider = $('#volume-slider')

    updateVolume = ->
      pipeline.setVolume Math.pow(10, volumeSlider.val() / 100)

    volumeSlider.change updateVolume
    updateVolume() # set initial volume

    $('#show-output-spectrum').click (e) ->
      if $(e.target).is('.enabled')
        specDisplay.analyser = pipeline.postAnalyser
      else
        specDisplay.analyser = pipeline.preAnalyser
      mgr.render()

    $('#enable-band-pass').click (e) ->
      if $(e.target).is('.enabled')
        mgr.add handle1, true
        mgr.add handle2, true
        mgr.add bandPassInd
        [freq, Q] = calculateBandPass()
        pipeline.bandPass.set 2, 8, freq, Q
        $('#band-pass-info').css 'display', 'block'
      else
        mgr.remove handle1
        mgr.remove handle2
        mgr.remove bandPassInd
        pipeline.bandPass.clear()
        $('#band-pass-info').css 'display', 'none'

    notchFilters = []

    updateNotchFilterInfo = ->
      info = $('#notch-filter-info')
      frequencies = ("#{Math.round(notchFilter.filter.frequency.value)} Hz" for notchFilter in notchFilters)
      frequencies = frequencies.join ', '
      info.text "Notch Filters: #{frequencies}"

    $('#add-notch-filter').click ->
      if notchFilters.length == 0
        $('#notch-filter-info').css 'display', 'block'
        $('#remove-notch-filter').css 'display', 'block'

      filter = pipeline.toneFilter.addFilter()
      notchFilter = new NotchFilter(filter)
      notchFilter.addTo mgr
      notchFilter.onMove = updateNotchFilterInfo
      notchFilters.push notchFilter
      updateNotchFilterInfo()

    $('#remove-notch-filter').click ->
      notchFilter = notchFilters.pop()
      pipeline.toneFilter.removeFilter notchFilter.filter
      notchFilter.removeFrom mgr
      updateNotchFilterInfo()

      if notchFilters.length == 0
        $('#notch-filter-info').css 'display', 'none'
        $('#remove-notch-filter').css 'display', 'none'