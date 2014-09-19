module.exports = class ClickOnAndWaitForElementByCss extends require '../action'
  clickOnAndWaitForElementByCssAction: (context, clickOn, waitFor, asserter, timeout = 10000) ->
    asserter or= timeout
    timeout = undefined if typeof asserter is 'number'

    context = do context
      .elementByCss clickOn
      .click

    if typeof waitFor is 'object'
      return @waitForTheFirstElementAction context, waitFor, asserter, timeout

    context.waitForElementByCss waitFor, asserter, timeout

  waitForTheFirstElementAction: (context, waitFor, asserter, timeout = 2000) ->
    asserter or= timeout
    timeout = undefined if typeof asserter is 'number'
    selectors = Object.keys waitFor

    context
      .noop()
      .then =>
        waitedElements = (@_browser.waitForElementByCss selector, asserter, timeout for selector in selectors )
        (require 'wd').Q.allSettled waitedElements
      .then (states) ->
        for result, index in states
          if result.state is 'fulfilled'
            return do waitFor[selectors[index]]

        throw new Error "Not found any of the requested elements: #{selectors}"

