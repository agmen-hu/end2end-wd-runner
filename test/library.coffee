Yadda = require 'yadda'
English = Yadda.localisation.English

dict = new Yadda.Dictionary()
  .define 'MILISEC', /(\d+)ms/
  .define 'OBJECT', /(\{.+\})/
  .define 'FILELIST', /(\[.+\])/

module.exports = ->
  English.library(dict)
    .given 'a config $OBJECT', (object) -> @context.config = JSON.parse object
