module.exports = class TestCase
  _actions: []

  constructor: (wd, @_browser, @_config, @errorHandler) ->
    new (require @_config.root + action) wd, @_browser, @_config, @errorHandler for action in @_actions

  setContext: (value) ->
    @_context = value
    return @

  test: -> @_context
  tearDown: ->
