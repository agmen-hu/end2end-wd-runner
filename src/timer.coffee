module.exports = class Timer
  start: ->
    @_overall = 0
    @_startedAt = do new Date().getTime

  getTime: ->
    now = do new Date().getTime
    current = now - @_startedAt
    @_overall += current
    @_startedAt = now

    current / 1000

  getOverall: ->
    do @getTime
    @_overall / 1000
