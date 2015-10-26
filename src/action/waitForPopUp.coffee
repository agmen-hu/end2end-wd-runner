{Action, Asserter} = require '../../main'

module.exports = class WaitForPopUp extends Action
  waitForPopUpAction: (context, waitFor, timeout = 10000) ->
    context
      .windowHandles()
      .waitFor (new Asserter @_waitForPopup), timeout

  _waitForPopup: (target) =>
    target
      .windowHandles()
      .then (handles) =>
        handles.should.have.length 2
        return handles

      .catch (err) ->
        err.retriable = true
        throw err
