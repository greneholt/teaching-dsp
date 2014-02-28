// Generated by CoffeeScript 1.6.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.CanvasManager = (function() {
    function CanvasManager(canvas) {
      var _this = this;
      this.canvas = canvas;
      this.ctx = this.canvas[0].getContext('2d');
      this.renderables = [];
      this.interactives = [];
      this.touches = {};
      this.touchCount = 0;
      this.canvas.mousedown(function(e) {
        if (_this.grab(0, e)) {
          return e.preventDefault();
        }
      });
      $(window).mouseup(function(e) {
        return _this.release(0, e);
      });
      $(window).mouseout(function(e) {
        if (e.target !== window) {
          return;
        }
        if (_this.touches[0] != null) {
          return _this.release(0, e);
        }
      });
      $(window).mousemove(function(e) {
        return _this.drag(0, e);
      });
      this.canvas.on('touchstart', function(e) {
        var stop, touch, _i, _len, _ref;
        stop = false;
        _ref = e.originalEvent.changedTouches;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          touch = _ref[_i];
          if (_this.grab(touch.identifier, touch)) {
            stop = true;
          }
        }
        if (stop) {
          return e.preventDefault();
        }
      });
      $(window).on('touchend', function(e) {
        var touch, _i, _len, _ref, _results;
        if (_this.touchCount > 0) {
          e.preventDefault();
        }
        _ref = e.originalEvent.changedTouches;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          touch = _ref[_i];
          _results.push(_this.release(touch.identifier, touch));
        }
        return _results;
      });
      $(window).on('touchmove', function(e) {
        var touch, _i, _len, _ref, _results;
        if (_this.touchCount > 0) {
          e.preventDefault();
        }
        _ref = e.originalEvent.changedTouches;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          touch = _ref[_i];
          _results.push(_this.drag(touch.identifier, touch));
        }
        return _results;
      });
    }

    CanvasManager.prototype.grab = function(id, e) {
      var o, x, y, _i, _len, _ref, _ref1;
      _ref = this.getPosition(e), x = _ref[0], y = _ref[1];
      _ref1 = this.interactives;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        o = _ref1[_i];
        if (o.grab(x, y)) {
          this.touches[id] = o;
          this.touchCount++;
          return true;
        }
      }
      return false;
    };

    CanvasManager.prototype.release = function(id, e) {
      if (this.touches[id] != null) {
        this.touches[id].release();
        delete this.touches[id];
        return this.touchCount--;
      }
    };

    CanvasManager.prototype.drag = function(id, e) {
      var x, y, _ref;
      if (this.touches[id] != null) {
        _ref = this.getPosition(e), x = _ref[0], y = _ref[1];
        this.touches[id].drag(x, y);
        return this.render();
      }
    };

    CanvasManager.prototype.add = function(object, interactive) {
      if (interactive == null) {
        interactive = false;
      }
      this.renderables.push(object);
      if (interactive) {
        this.interactives.unshift(object);
      }
      return this.render();
    };

    CanvasManager.prototype.remove = function(object) {
      this.arrayRemove(object, this.renderables);
      this.arrayRemove(object, this.interactives);
      return this.render();
    };

    CanvasManager.prototype.render = function() {
      var height, renderable, width, _i, _len, _ref, _results;
      width = this.canvas[0].width;
      height = this.canvas[0].height;
      this.ctx.clearRect(0, 0, width, height);
      _ref = this.renderables;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        renderable = _ref[_i];
        _results.push(renderable.render(this.ctx, width, height));
      }
      return _results;
    };

    CanvasManager.prototype.arrayRemove = function(object, array) {
      var index;
      index = array.indexOf(object);
      if (index !== -1) {
        return array.splice(index, 1);
      }
    };

    CanvasManager.prototype.getPosition = function(e) {
      var mouseX, mouseY, offset;
      offset = this.canvas.offset();
      mouseX = e.pageX - offset.left;
      mouseY = e.pageY - offset.top;
      return [mouseX, mouseY];
    };

    return CanvasManager;

  })();

}).call(this);
