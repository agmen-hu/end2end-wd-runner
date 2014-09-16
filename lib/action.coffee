module.exports = class Base
  constructor: (wd, @_browser, @_config, @errorHandler) ->
    self = @;
    for property of self
      actionMethodName = property.match /(.+)Action$/
      if actionMethodName and typeof self[property] is 'function'
        wd.addPromiseChainMethod(
          actionMethodName[1],
          do (property, actionMethodName) ->->
            args = Array::slice.call arguments
            console.log "#{actionMethodName[1]} called" + if arguments.length then " with #{args}" else ''
            args.splice 0, 0, @
            self[property].apply self, args
        )

  _nothing: =>
    do @_browser.noop

