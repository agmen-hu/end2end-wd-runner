{Action, Asserter} = require '../../main'

module.exports = class WaitForPopUp extends Action
  waitForPopUpAction: (context, waitFor, timeout = 10000) ->
    context
      .windowHandles()
      .then (handles) => @_windowCount = handles.length
      .waitFor new Asserter @_waitForPopup, timeout

  _waitForPopup: (target) =>
    target
      .windowHandles()
      .then (handles) =>
        handles.should.have.length @_windowCount + 1
        return handles

      .fail (err) ->
        err.retriable = true
        throw err
