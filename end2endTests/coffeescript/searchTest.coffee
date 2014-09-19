module.exports = class SearchTest extends require('../../main').TestCase
  _actions: [
    'coffeescript/action/search'
  ]

  test: ->
    @_context
      # the first context does not have the custom actions
      .noop()
      .search 'google'
      .search 'bing'

  tearDown: ->
    console.log 'search test finished'
    # must return a promise
    # the context which is returned by the test method
    do @_context.noop
