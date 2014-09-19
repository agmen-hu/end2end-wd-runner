module.exports = class TestCase
  _actions: []

  constructor: (wd, @_browser, @_config, @errorHandler) ->
    new (require @_config.root + action) wd, @_browser, @_config, @errorHandler for action in @_actions

  setContext: (value) ->
    @_context = value
    return @

  runTest: ->
    @_context = do @test

  test: -> @_context

  tearDown: -> @_context
