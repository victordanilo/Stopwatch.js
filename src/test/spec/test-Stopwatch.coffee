describe 'Stopwatch', ->
  it 'should be cross-platform', ->
    expect(new Stopwatch).to.be.instanceOf Stopwatch
    expect(new module.exports).to.be.instanceOf Stopwatch
    expect(defined).to.contain 'Stopwatch'

  describe '#start()', ->
    now =
    timer =

    beforeEach ->
      timer = new Stopwatch()
      now = new Date().valueOf()
      timer.start()

    it 'should be properly initialized', ->
      expect(timer.started).to.be.true
      expect(timer.previousElapsed).to.equal 0
      expect(timer.running).to.true
      expect(timer.startTime).to.be.a 'number'

    it 'should be keeping track of time', ->
      expect(Math.abs(timer.startTime - now)).to.be.within 0, 50

    it 'should be idempotent while already started', (done) ->
      _verify = ->
        timer.start()
        expect(Math.abs(timer.startTime - now)).to.be.within 0, 50
        done()

      setTimeout _verify, 100

  describe '#pause()', ->
    timer =

    beforeEach ->
      timer = new Stopwatch()

    it 'should no longer be running', ->
      timer.start()
      timer.pause()
      expect(timer.running).to.be.false

    it 'should not reset elapsed', (done) ->
      timer.start()

      _verify = ->
        timer.pause()
        expect(timer.getElapsed()).to.be.above 0
        done()

      setTimeout _verify, 100

    it 'should resume at previously paused elapsed time', (done) ->
      timer.start()
      elapsed = 0

      _pause = ->
        timer.pause()
        elapsed = timer.getElapsed()

      _verify = ->
        timer.start()
        expect(timer.getElapsed() - elapsed).to.be.within 0, 50
        done()

      setTimeout _pause, 150
      setTimeout _verify, 350

  describe '#stop()', ->
    it 'should no longer be running', ->
      timer = new Stopwatch()
      timer.start()
      timer.stop()
      expect(timer.running).to.be.false

    it 'should no longer be started', ->
      timer = new Stopwatch()
      timer.start()
      timer.stop()
      expect(timer.started).to.be.false

    it 'should re-initialize when re-started', (done) ->
      timer = new Stopwatch()
      timer.start()
      _checkExpected = ->
        timer.stop()
        timer.start()

        expect(timer.previousElapsed).to.equal 0
        expect(Math.abs(timer.startTime - new Date().valueOf())).to.be.within 0, 50
        done()

      setTimeout _checkExpected, 51

    it 'should reset elapsed', (done) ->
      timer = new Stopwatch()
      timer.start()

      _verify = ->
        timer.stop()
        expect(timer.getElapsed()).to.equal 0
        done()

      setTimeout _verify, 100

    it 'should be permitted during a pause', (done) ->
      timer = new Stopwatch()
      timer.start()

      _verify = ->
        timer.pause()
        timer.stop()
        expect(timer.getElapsed()).to.equal 0
        done()

      setTimeout _verify, 100

  describe '#getElapsed()', ->
    it 'should keep track of time', (done) ->
      timer = new Stopwatch()
      timer.start()
      _checkExpected = ->
        expect(timer.getElapsed()).to.be.within 950, 1050
        done()

      setTimeout _checkExpected, 1000

  describe '#setStartTime()', ->
    time =

    beforeEach ->
      timer = new Stopwatch()

      it 'should set the start time of the count', (done) ->
        timer.setStartTime('01:22:35');

        _verify = ->
          timer.start()
          expect(timer.getElapsed()).to.be.above 0
          done()

        setTimeout _verify, 100

  describe '#onTick()', ->
    it 'should tick once a second by default', (done) ->
      timer = new Stopwatch()

      timer.onTick ->
        expect(timer.getElapsed()).to.be.within 950, 1050
        timer.stop()
        done()

      timer.start()

    it 'should only tick if timer is running', (done) ->
      timer = new Stopwatch()

      _err = -> throw new Error 'tick occured when not started'

      timer.onTick _err, 500
      setTimeout done, 1000

    it 'should allow multiple handlers', (done) ->
      timer = new Stopwatch()

      a = b = false
      _checkDone = ->
        if a && b && timer.running
          timer.stop()
          done()

      timer.onTick =>
          a = true
          _checkDone()
      timer.onTick =>
          b = true
          _checkDone()

      timer.start()

  describe '#toString()', ->
    it 'should return value in hh:mm:ss.sss format', ->
      timer = new Stopwatch()
      expect('' + timer).to.match /^\d{2}:\d{2}:\d{2}\.\d{3}$/

    it 'should return a string representing the current elapsed time', ->
      timer = new Stopwatch()
      timer.previousElapsed = 671000 # 11min 11sec
      expect('' + timer).to.match /^00:11:11\.\d{3}$/

