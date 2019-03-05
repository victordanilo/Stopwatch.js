class Stopwatch
  constructor: ->
    @tickIntervals = []
    @started = false
    @running = false
    @previousElapsed = 0

  start: ->
    return if @running
    @startTime = new Date().valueOf()
    @_updateTickIntervals()
    @running = true
    @started = true

  pause: ->
    return unless @running
    clearCorrectingInterval(+tick.intervalId) for tick in @tickIntervals when tick.intervalId?
    @running = false
    @previousElapsed = @getElapsed()
    @startTime = null

  stop: ->
    @pause() if @running
    @previousElapsed = 0
    @started = false

  getElapsed: ->
    now = new Date().valueOf()
    startTime = @startTime or now
    return now - startTime + @previousElapsed

  setStartTime: (timeString) ->
    return if @running
    format = /^\d{2}:\d{2}:\d{2}$/
    throw new Error("timeString format is invalid, accepted format is '00:00:00'") unless format.test(timeString)
    time = timeString.split(':');
    hr = time[0]
    min = time[1]
    sec = time[2]
    startTime = 0
    startTime += hr * 3600000
    startTime += min * 60000
    startTime += sec * 1000
    @.previousElapsed = startTime

  onTick: (callback, resolution = 1000, startImmediate = false) ->
    throw new TypeError('Must provide a valid callback function') unless typeof callback is 'function'

    unless @running
      @_setTick callback, resolution, true
    else if startImmediate or @getElapsed() is 0
      @_startTicking callback, resolution, true
    else
      nextTick = resolution - (@getElapsed() % resolution)
      startTicking = => @_startTicking callback, resolution
      setTimeout startTicking, nextTick

  toString: ->
    duration = @getElapsed()
    ms = duration % 1000
    duration = (duration - ms) / 1000
    sec = duration % 60
    duration = (duration - sec) / 60;
    min = duration % 60
    hr = (duration - min) / 60

    return ('0' + hr).slice(-2) + ':' +
      ('0' + min).slice(-2) + ':' +
      ('0' + sec).slice(-2) + '.' +
      ('00' + ms).slice(-3)

  _startTicking: (callback, resolution) ->
    tick = @_setTick callback, resolution
    tick.intervalId = setCorrectingInterval callback, resolution

  _setTick: (callback, resolution) ->
    tick = new TickInterval callback, resolution, new Date().valueOf()
    @tickIntervals.push tick
    tick

  _updateTickIntervals: ->
    intervalIds = []

    for intervalId, ticker of @tickIntervals
      # Create bound context to retain ticker when setTimeout resolves
      _this = @
      startTicking = (-> _this._startTicking @callback, @resolution).bind(ticker)

      # Calculate time until next tick, whereupon the timer should begin ticking
      elapsed = new Date().valueOf() - ticker.startTime
      nextTick = Math.abs ticker.resolution - (elapsed % ticker.resolution)

      if not @running or nextTick % ticker.resolution is 0
        setTimeout startTicking, 0
      else
        setTimeout startTicking, nextTick

    @tickIntervals = []

class TickInterval
  constructor: (@callback, @resolution, @startTime) ->

@Stopwatch = Stopwatch
module.exports = Stopwatch if module?.exports?
if typeof define is 'function' and define.amd?
  define 'Stopwatch', -> Stopwatch
