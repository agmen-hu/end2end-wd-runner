Q = (require 'wd').Q

class ReadLine
  pauseUntilAnyKey: ->
    deferred = do Q.defer
    @_createInterface().question '\nPress any key to continue...\n'
      , -> do deferred.resolve
      
    return deferred.promise
    
  _createInterface: ->
    require('readline').createInterface
      input: process.stdin
      output: process.stdout


module.exports = new ReadLine()