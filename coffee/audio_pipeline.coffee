makeFilter = (context, inputNode, type, frequency, Q, order) ->
  lastNode = inputNode;

  for i in [1..order]
    filter = context.createBiquadFilter()
    filter.type = type
    filter.frequency.value = frequency
    filter.Q.value = Q
    lastNode.connect(filter)
    lastNode = filter

  return lastNode

class AudioPipeline
  constructor: (@context) ->
    @firstNode = null


  connectSource: (source) ->
