module.exports = class ClickOnAndForElement extends require '../action'
  clickOnAndWaitForElementByCssAction: (context, clickOn, waitFor, asserter, timeout = 2000) ->
    asserter or= timeout
    timeout = undefined if typeof asserter is 'number'

    context = do context
      .elementByCss clickOn
      .click

    if typeof waitFor is 'object'
      return @_createWaitForMultipleElement context, waitFor, asserter, timeout

    context.waitForElementByCss waitFor, asserter, timeout

  _createWaitForMultipleElement: (context, waitFor, asserter, timeout) ->
    selectors = Object.keys waitFor

    context
      .then =>
        waitedElements = (@_browser.waitForElementByCss selector, asserter, timeout for selector in selectors )
        (require 'wd').Q.allSettled waitedElements
      .then (states) ->
        for result, index in states
          if result.state is 'fulfilled'
            return do waitFor[selectors[index]]

        throw new Error "Not found any of the requested elements: #{selectors}"

