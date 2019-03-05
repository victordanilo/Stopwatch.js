/*! Stopwatch.js 1.0.0 | (c) 2019 Andrew Duthie <andrew@andrewduthie.com> | MIT License */
(function() {
  var Stopwatch, TickInterval;

  Stopwatch = (function() {
    function Stopwatch() {
      this.tickIntervals = [];
      this.started = false;
      this.running = false;
      this.previousElapsed = 0;
    }

    Stopwatch.prototype.start = function() {
      if (this.running) {
        return;
      }
      this.startTime = new Date().valueOf();
      this._updateTickIntervals();
      this.running = true;
      return this.started = true;
    };

    Stopwatch.prototype.pause = function() {
      var tick, _i, _len, _ref;
      if (!this.running) {
        return;
      }
      _ref = this.tickIntervals;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tick = _ref[_i];
        if (tick.intervalId != null) {
          clearCorrectingInterval(+tick.intervalId);
        }
      }
      this.running = false;
      this.previousElapsed = this.getElapsed();
      return this.startTime = null;
    };

    Stopwatch.prototype.stop = function() {
      if (this.running) {
        this.pause();
      }
      this.previousElapsed = 0;
      return this.started = false;
    };

    Stopwatch.prototype.getElapsed = function() {
      var now, startTime;
      now = new Date().valueOf();
      startTime = this.startTime || now;
      return now - startTime + this.previousElapsed;
    };

    Stopwatch.prototype.setStartTime = function(timeString) {
      var format, hr, min, sec, startTime, time;
      if (this.running) {
        return;
      }
      format = /^\d{2}:\d{2}:\d{2}$/;
      if (!format.test(timeString)) {
        throw new Error("timeString format is invalid, accepted format is '00:00:00'");
      }
      time = timeString.split(':');
      hr = time[0];
      min = time[1];
      sec = time[2];
      startTime = 0;
      startTime += hr * 3600000;
      startTime += min * 60000;
      startTime += sec * 1000;
      return this.previousElapsed = startTime;
    };

    Stopwatch.prototype.onTick = function(callback, resolution, startImmediate) {
      var nextTick, startTicking,
        _this = this;
      if (resolution == null) {
        resolution = 1000;
      }
      if (startImmediate == null) {
        startImmediate = false;
      }
      if (typeof callback !== 'function') {
        throw new TypeError('Must provide a valid callback function');
      }
      if (!this.running) {
        return this._setTick(callback, resolution, true);
      } else if (startImmediate || this.getElapsed() === 0) {
        return this._startTicking(callback, resolution, true);
      } else {
        nextTick = resolution - (this.getElapsed() % resolution);
        startTicking = function() {
          return _this._startTicking(callback, resolution);
        };
        return setTimeout(startTicking, nextTick);
      }
    };

    Stopwatch.prototype.toString = function() {
      var duration, hr, min, ms, sec;
      duration = this.getElapsed();
      ms = duration % 1000;
      duration = (duration - ms) / 1000;
      sec = duration % 60;
      duration = (duration - sec) / 60;
      min = duration % 60;
      hr = (duration - min) / 60;
      return ('0' + hr).slice(-2) + ':' + ('0' + min).slice(-2) + ':' + ('0' + sec).slice(-2) + '.' + ('00' + ms).slice(-3);
    };

    Stopwatch.prototype._startTicking = function(callback, resolution) {
      var tick;
      tick = this._setTick(callback, resolution);
      return tick.intervalId = setCorrectingInterval(callback, resolution);
    };

    Stopwatch.prototype._setTick = function(callback, resolution) {
      var tick;
      tick = new TickInterval(callback, resolution, new Date().valueOf());
      this.tickIntervals.push(tick);
      return tick;
    };

    Stopwatch.prototype._updateTickIntervals = function() {
      var elapsed, intervalId, intervalIds, nextTick, startTicking, ticker, _ref, _this;
      intervalIds = [];
      _ref = this.tickIntervals;
      for (intervalId in _ref) {
        ticker = _ref[intervalId];
        _this = this;
        startTicking = (function() {
          return _this._startTicking(this.callback, this.resolution);
        }).bind(ticker);
        elapsed = new Date().valueOf() - ticker.startTime;
        nextTick = Math.abs(ticker.resolution - (elapsed % ticker.resolution));
        if (!this.running || nextTick % ticker.resolution === 0) {
          setTimeout(startTicking, 0);
        } else {
          setTimeout(startTicking, nextTick);
        }
      }
      return this.tickIntervals = [];
    };

    return Stopwatch;

  })();

  TickInterval = (function() {
    function TickInterval(callback, resolution, startTime) {
      this.callback = callback;
      this.resolution = resolution;
      this.startTime = startTime;
    }

    return TickInterval;

  })();

  this.Stopwatch = Stopwatch;

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = Stopwatch;
  }

  if (typeof define === 'function' && (define.amd != null)) {
    define('Stopwatch', function() {
      return Stopwatch;
    });
  }

}).call(this);
