sinon = require 'sinon'
Timer = require '../../src/timer'

library = (require '../library')()
    .given 'a new Timer', ->
      @context.clock = do sinon.useFakeTimers
      @context.timer = new Timer()

    .when 'start called since $MILISEC', (milisec) ->
      do @context.timer.start
      @context.clock.tick milisec * 1000

    .then 'time is $MILISEC', (milisec) ->
      @context.timer.getTime().should.be.eql milisec * 1

    .when 'time is passed by $MILISEC', (milisec) ->
      @context.clock.tick milisec * 1000

    .then 'the overall time since the timer started is $MILISEC', (milisec) ->
      @context.timer.getOverall().should.be.eql milisec * 1

library.afterEach = ->
  do @context.clock.restore

module.exports = library
