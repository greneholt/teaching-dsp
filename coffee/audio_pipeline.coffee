root = exports ? this

class MultiStageFilter
  constructor: (@context) ->
    @filters = []

  set: (type, order, frequency, Q) ->
    this.disconnect()

    last = null
    @filters = []

    for i in [1..order]
      filter = @context.createBiquadFilter()
      filter.type = type
      filter.frequency.value = frequency
      filter.Q.value = Q
      last.connect filter if last?
      last = filter
      @filters.push filter

    this.connect @from, @to

  disconnect: ->
    @from.disconnect 0 if @from?
    @filters[@filters.length - 1].disconnect 0 if @filters.length > 0

  connectTo: (@to) ->
    if @filters.length > 0
      @filters[@filters.length - 1].connect @to
    else
      @from.connect @to if @from?

  connectFrom: (@from) ->
    if @filters.length > 0
      @from.connect @filters[0]
    else
      @from.connect @to if @to?

  connect: (@from, @to) ->
    this.connectTo @to
    this.connectFrom @from

  setFrequency: (frequency) ->
    for filter in @filters
      filter.frequency.value = frequency

  setQ: (Q) ->
    for filter in @filters
      filter.Q.value = Q

class MultiNotchFilter
  constructor: (@context) ->
    @filters = []

  addFrequency: (frequency) ->
    filter = @context.createBiquadFilter()
    filter.type = 2
    filter.frequency.value = frequency
    filter.Q.value = 500

    if @filters.length > 0
      # disconnect the previous end of the chain
      @filters[@filters.length - 1].disconnect 0
      @filters[@filters.length - 1].connect filter
    else if @from? # its the first filter, connect it to the source
      @from.disconnect 0
      @from.connect filter

    filter.connect @to if @to?
    @filters.push filter

  removeFilter: (i) ->
    filter = @filters[i]
    filter.disconnect 0

    # remove this filter from the chain
    if i == 0
      @from.disconnect 0 if @from?
    else
      @filters[i - 1].disconnect 0

    # reconnect the chain
    if @filters.length == 1 # this was the only filter
      @from.connect @to if @from?
    else if i == 0 # this was the first filter in the chain
      @from.connect @filters[i + 1] if @from?
    else if i == @filters.length - 1 # this was the last filter in the chain
      @filters[i - 1].connect @to if @to?
    else
      @filters[i - 1].connect @filters[i + 1]

    @filters.splice i, 1 # remove filter from array

  removeFrequency: (frequency) ->
    for i, filter in @filters
      if filter.frequency.value == frequency
        this.removeFilter i
        return true
    return false

  disconnect: ->
    @from.disconnect 0 if @from?
    @filters[@filters.length - 1].disconnect 0 if @filters.length > 0

  connectTo: (@to) ->
    if @filters.length > 0
      @filters[@filters.length - 1].connect @to
    else
      @from.connect @to if @from?

  connectFrom: (@from) ->
    if @filters.length > 0
      @from.connect @filters[0]
    else
      @from.connect @to if @to?

  connect: (@from, @to) ->
    this.connectTo @to
    this.connectFrom @from

  setFrequency: (i, frequency) ->
    @filters[i].frequency.value = frequency

class root.AudioPipeline
  constructor: (@context, @noiseBuffer) ->
    @voiceVolume = @context.createGainNode()

    @voiceFilter = new MultiStageFilter @context
    @voiceFilter.connectFrom @voiceVolume

    @noiseFilter = new MultiStageFilter @context

    @preAnalyser = @context.createAnalyser()
    @preAnalyser.smoothingTimeConstant.value = 100

    @voiceFilter.connectTo @preAnalyser

    @noiseFilter.connectTo @preAnalyser

    @oscillators = []

    @bandPass = new MultiStageFilter @context
    @bandPass.connectFrom @preAnalyser

    @volume = @context.createGainNode()

    @bandPass.connectTo @volume

    @toneFilters = new MultiNotchFilter @context
    @toneFilters.connectFrom @volume

    @postAnalyser = @context.createAnalyser()
    @postAnalyser.smoothingTimeConstant.value = 100

    @toneFilters.connectTo @postAnalyser

    @postAnalyser.connect @context.destination

  setInterference: (voiceF, voiceQ, tones) ->
    for osc in @oscillators
      osc.disconnect 0

    @oscillators = for freq in tones
      osc = @context.createOscillator()
      osc.frequency.value = freq
      osc.connect destination
      osc

    @voiceFilter.set 2, 8, voiceF, voiceQ

    @noiseFilter.set 6, 8, voiceF, voiceQ

  play: (voiceBuffer) ->
    noise = @context.createBufferSource(@noiseBuffer, true)
    voice = @context.createBufferSource(voiceBuffer, true)

    noise.noteOn 0
    voice.noteOn 3

    noise.noteOff 3 + voiceBuffer.length