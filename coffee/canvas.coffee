root = exports ? this

canvasManager = null

CanvasManager = root.CanvasManager
DragHandle = root.DragHandle
SpectrumDisplay = root.SpectrumDisplay

context = null
specDisplay = null
voiceBuffer = null
noiseBuffer = null

makeFilter = (inputNode, type, frequency, Q, order) ->
  lastNode = inputNode;

  for i in [1..order]
    filter = context.createBiquadFilter()
    filter.type = type
    filter.frequency.value = frequency
    filter.Q.value = Q
    lastNode.connect filter
    lastNode = filter

  return lastNode

loadSound = (url, callback) ->
  request = new XMLHttpRequest()
  request.open('GET', url, true)
  request.responseType = 'arraybuffer'

  # Decode asynchronously
  request.onload = ->
    context.decodeAudioData request.response, callback

  request.send()

loadSound 'atlys.mp3', (buffer) ->
  voiceBuffer = buffer

loadSound 'noise.mp3', (buffer) ->
  noiseBuffer = buffer

makeSourcePipeline = (voiceBuffer, voiceF, voiceQ, voiceGain, tones, destination) ->
  sources = []

  voice = context.createBufferSource();
  voice.buffer = voiceBuffer

  sources.push voice

  noise = context.createBufferSource();
  noise.buffer = noiseBuffer

  sources.push noise

  voice = makeFilter voice, 2, voiceF, voiceQ, 8

  gain = context.createGainNode()
  gain.gain.value = voiceGain
  voice.connect gain

  noise = makeFilter noise, 6, voiceF, voiceQ, 8

  gain.connect destination
  noise.connect destination

  for freq in tones
    osc = context.createOscillator()
    osc.frequency.value = freq
    osc.connect destination
    sources.push osc

  return sources

makeFilterPipeline = (source, bandPassF, bandPassQ, tones, destination) ->
  for freq in tones
    source = makeFilter source, 6, freq, 500, 1

  source = makeFilter source, 2, bandPassF, bandPassQ, 8

  source.connect destination

$(document).ready ->
  context = new webkitAudioContext()

  canvas = $('canvas')
  canvasManager = new CanvasManager(canvas)

  handle1 = new DragHandle(canvasManager, 20, 300, 30, 40, {constrainY: true})
  handle2 = new DragHandle(canvasManager, 40, 300, 30, 40, {constrainY: true})

  specDisplay = new SpectrumDisplay(canvasManager, 0, 0, 600, 300)

  setInterval ->
    canvasManager.render()
  , 30

  $('#play-button').click ->
    preAnalyser = context.createAnalyser()
    preAnalyser.smoothingTimeConstant.value = 100

    sources = makeSourcePipeline voiceBuffer, 1500, 1, 1, [900, 1100, 1300, 1500, 1700, 1900], preAnalyser

    volume = context.createGainNode()
    volume.gain.value = 5

    postAnalyzer = context.createAnalyser()
    postAnalyzer.smoothingTimeConstant.value = 100

    makeFilterPipeline preAnalyser, 1500, 1, [900, 1100, 1300, 1500, 1700, 1900], volume

    volume.connect postAnalyzer

    postAnalyzer.connect context.destination

    specDisplay.analyser = postAnalyzer

    for source in sources
      source.noteOn 0
      source.noteOff 20