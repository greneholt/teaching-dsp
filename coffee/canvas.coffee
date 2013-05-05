root = exports ? this

canvasManager = null

CanvasManager = root.CanvasManager
DragHandle = root.DragHandle

$(document).ready ->
  canvas = $('canvas')
  canvasManager = new CanvasManager(canvas)

  handle = new DragHandle(canvasManager)

  canvasManager.render()