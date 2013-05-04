toLoad = 1

mouseX = 0
mouseY = 0
scene = null

root = exports ? this

handle = new Image();
handle.src = "play.svg"
handle.onload = ->
  toLoad--
  newLoaded()

newLoaded = ->
  if toLoad == 0
    $(document).ready ->
      canvas = $('canvas')
      scene = new root.Scene(canvas)

      canvas.bind 'mousemove', (e) ->
        offset = canvas.offset()
        mouseX = e.pageX - offset.left
        mouseY = e.pageY - offset.top

      setInterval ->
        scene.render
      , 30