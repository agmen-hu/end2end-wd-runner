chai = require 'chai'
sinon = require 'sinon'
Yadda = require 'yadda'
Timer = require '../../src/timer'
Dictionary = Yadda.Dictionary
English = Yadda.localisation.English

do chai.should

module.exports = do ->
  timer = undefined
  clock = undefined

  dictionary = new Dictionary()
    .define 'MILISEC', /(\d+)ms/

  library = English.library dictionary

  library.afterEach = ->
    do clock.restore

  library
    .given 'a new Timer', ->
      clock = do sinon.useFakeTimers
      timer = new Timer()

    .when 'start called since $MILISEC', (milisec) ->
      do timer.start
      clock.tick milisec * 1000

    .then 'time is $MILISEC', (milisec) ->
      timer.getTime().should.be.eql milisec * 1

    .when 'time is passed by $MILISEC', (milisec) ->
      clock.tick milisec * 1000

    .then 'the overall time since the timer started is $MILISEC', (milisec) ->
      timer.getOverall().should.be.eql milisec * 1
