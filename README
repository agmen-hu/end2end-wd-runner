# end2end-wd-runner
---

####All in end to end test runner for wd.js

* grep / exlude for test files
* includeable yml configuration
* tearDownable testcases
* custom actions for the readable tests
* included selenium with firefox, chrome and phantomjs driver

## Pre-requests

* installed phantomjs for phantomjs driver :)
* coffee script (at the moment...)

## Install

```
npm install -g end2end-wd-runner
```

## Usage

```
end2end
# use the end2endTests folder as root directory
# and search all the *Test.* file recursive
# except which are have 'manually' in their path or name

end2end -r other/root/folder
```
```
# for more :)
end2end --help
```

## Configuration

defaults
```yml
# passthrough for the wd.promiseChainRemote
wdRemote: ~
# passthrough for the wd.browser.init
browser:
  browserName: 'firefox'
onError:
  takeScreenShot: false
  sleep: 0
runner:
  grep: ''
  exclude: manually
  startTestsWithNewBrowser: false
```

include possibility:

```yml
#otherConfigs.yml
user:
  name: Test
  password: 1234

#config.yml
include: [ otherConfigs.yml ]
url: http://localhost/project
mysql:
  password: 12345

#production.yml
include: [ otherConfigs.yml ]
url: http://project.com
mysql:
  password: 6789
user:
  password: $dsf@12#De6
```

```
end2end #run with localhost configuration
end2end -c production.yml
```

## Examples

end2end use the wd with promise chains so the Actions basically a set of methods for promise chain.

```coffeescript
module.exports = class Search extends require('../../main').Action
  # all method which is ending with Action added to the wd
  searchAction: (context, where) ->
    context
      .get @_config.urls[where] + @_config.search.forWhat
      .pageHasWikipediaShortcut where

  pageHasWikipediaShortcutAction: (context, where) ->
    # must return a promise hence the shortcut for the browser.noop
    return do @_nothing if where isnt 'google'

    context
      .hasElementById 'rcnt'
      .then (exists) => if exists then do @_shourtCutFound else do @_nothing

  _shourtCutFound: ->
    console.log 'Page has a wikipedia shortcut'
    do @_nothing
```

TestCase
```coffeescript
module.exports = class SearchTest extends require('../main').TestCase
  _actions: [
    'action/search'
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
```

The Action and the TestCase share the same sets of property
```coffeescript
@_config
# the wd browser
@_browser
# callback for the deeper promise chain error handling
@errorHandler
```
## Built-in actions over the wd

#### ClickOnAndForElementByCss (context, clickOn, waitFor, asserter, timeout = 10000)

Shortcut for:
```coffeescript
context
    .elementByCss clickOn, asserter, timout
    .click()
    .waitForElementByCss waitFor
```

plus the waitFor can be an object where the keys are the selectors and the values are the callbacks and the first arrived called
