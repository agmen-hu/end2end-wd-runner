{Q} = require '../../main'
module.exports = class ClickOnAndWaitForElementByCss extends require '../action'
  clickOnAndWaitForElementByCssAction: (context, clickOn, waitFor, asserter, timeout) ->
    asserter or= timeout
    timeout = undefined if typeof asserter is 'number'

    context = do context
      .elementByCss clickOn
      .click

    if typeof waitFor is 'object'
      return @waitForTheFirstElementByCssAction context, waitFor, asserter, timeout

    context.waitForElementByCss waitFor, asserter, timeout

  waitForTheFirstElementByCssAction: (context, waitFor, asserter, timeout) ->
    asserter or= timeout
    timeout = undefined if typeof asserter is 'number'
    selectors = Object.keys waitFor
    deferred = do Q.defer

    context
      .noop()
      .then =>
        for selector in selectors
          @_browser
            .waitForElementByCss selector, asserter, timeout
            .then (do (selector) ->->
              return true if not deferred.promise.isPending()
              deferred.resolve selector)

            .fail ->
              return true if not deferred.promise.isPending()
              do deferred.reject

    deferred.promise
      .fail -> throw new Error "Not found any of the requested elements: #{selectors}"
      .then (selector) -> do waitFor[selector]
