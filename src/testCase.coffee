Q = (require 'wd').Q

module.exports = class TestCase
  _actions: []

  constructor: (wd, @_browser, @_config) ->
    new (require @_config.root + action) wd, @_browser, @_config for action in @_actions

  runTest: => do @test

  test: -> do @_browser.chain

  runTearDown: ->
    deferred = do Q.defer

    try
      @tearDown()
      .then deferred.resolve
      .fail deferred.reject
    catch error
      deferred.reject error

    return deferred.promise

  tearDown: -> do @_browser.chain
