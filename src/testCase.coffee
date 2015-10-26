Q = (require 'wd').Q

module.exports = class TestCase
  constructor: ({ @wd, browser: @_browser, config: @_config, @logger }) ->

  useMixins: (mixins) ->
    @useMixin mixin for mixin in mixins

  useMixin: (mixin) ->
    new mixin
      wd: @wd
      browser: @_browser
      config: @_config
      logger: @logger
      testcase: @

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
