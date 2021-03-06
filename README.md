# end2end-wd-runner

####All in end to end test runner for wd.js

* grep / exlude for test files
* includeable yml configuration
* tearDownable testcases
* custom actions for the readable tests
* included selenium-standalone module with firefox, chrome and phantomjs driver
  (this will be installed only after the first run is detect that is missing)

## Pre-requests

* installed phantomjs for phantomjs driver

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
# all options
-r --root <directory>                    root directory for text search. Default is end2endTests
-c --config <path>                       path to config yml. Default is root/config.yml
-b --browser <firefox|chrome|phantomjs>  Default is come from the config
-g --grep <pattern>                      regexp matcher for wich tests being executed
-e --exclude <pattern>                   regexp matcher for wich tests being excluded. Default is manually
```

## Configuration

defaults
```yml
# passthrough for the wd.promiseChainRemote
# when it is not null the built in selenium does not started
wdRemote: ~
# passthrough for the wd.browser.init
browser:
  browserName: 'firefox'
logger:
  # absolute path, relative from the root or relative from the module
  class: 'lib/logger.js'
  # passthrough to the logger constructor
  config:
    level: 'info'
onError:
  # collect console logs from the browser with the same level trashold as the logger
  collectLogsFromBrowser: false
  startNewBrowser: false
  takeScreenShot: false
  # pause until a key pressed
  pause: false
  # sleep x millisecond
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

### TestSuites

With test suites we can run all the test files (or just some) with different configuration at once

```yml
include:
  - config.yml

onError:
  pause: false

testSuites:
  # this one run with the config from the main include
  AdaLovelace:

  CharlesBabbage:
    include:
      - config_charlesBabbage.yml

  DennisMRitchie:
    # everything is overrideable except the selenium and the testSuites configurations
    override:
      search:
        forWhat: 'Dennis M. Ritchie'
      browser:
        browserName: 'chrome'
      logger:
        config:
          level: 'debug'

  onlyJavascript:
    override:
      # root also changeable with relative from the current root or absolute path
      root: ../end2endTests
      runner:
        grep: javascript/.+
```

## Examples

end2end use the wd with promise chains so the Actions basically a set of methods for promise chain.
See the end2endTests folder for the whole tests

```coffeescript
module.exports = class Search extends require('end2end-wd-runner').Action
  # all method which is ending with Action added to the wd
  searchAction: (context, where) ->
    context
      .get @_config.urls[where] + @_config.search.forWhat
      .then => @logger.debug 'url loaded', url: @_config.urls[where], what: @_config.search.forWhat
      .pageHasWikipediaShortcut where

  pageHasWikipediaShortcutAction: (context, where) ->
    # @_nothing is a shortcut for browser.noop
    return do @_nothing if where isnt 'google'

    context
      .hasElementById 'rcnt'
      .then (exists) => if exists then do @_shourtCutFound else do @_nothing

  _shourtCutFound: ->
    @logger.info 'Page has a wikipedia shortcut'
```

TestCase
```coffeescript
module.exports = class SearchTest extends require('end2end-wd-runner').TestCase
  _actions: [
    'action/search'
  ]

  # a promise must be returned
  test: ->
    @_browser
      .search 'google'
      .search 'bing'

  # a promise must be returned
  tearDown: ->
    @logger.info 'search test finished'
    do @_browser.chain
```

If you prefer javascript:
```javascript
module.exports = SearchTest = require('end2end-wd-runner').createNewTestCase();
// there is also available a createNewAction method

SearchTest.prototype._actions = [
  'action/search'
]

// a promise must be returned
SearchTest.prototype.test = function()
{
  return this._browser
    .search('google')
    .search('bing');
}

// a promise must be returned
SearchTest.prototype.tearDown = function()
{
  this.logger.info('search test finished');
  this._browser.chain();
}
```

The Action and the TestCase share the same sets of property
```coffeescript
@_config
# the wd browser
@_browser
# Simple logger for console with debug/info/warn/error methods
@logger
# callback for the deeper promise chain error handling
@errorHandler
```
## Built-in actions over the wd

#### waitForTheFirstElementByCss (waitFor, asserter, timeout)

waitFor argument is an object where the keys are the selectors and the values are the callbacks

#### clickOnAndWaitForElementByCss (clickOn, waitFor, asserter, timeout)

Shortcut for:
```coffeescript
context
    .elementByCss clickOn
    .click()
    .waitForElementByCss waitFor, asserter, timout
```

When the waitFor is an object then waitForTheFirstElementByCss action used

#### waitForPopUp()

Wait for a second window is opened

#### pause()

Pause the test until a key is pressed
