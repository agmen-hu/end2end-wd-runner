module.exports = class BrowserLogCollector
  constructor: (@logger) ->

  collect: (browser) ->
    browser
      .log 'browser'
      .then (rows) =>
        for row in rows
          level = do row.level.toLowerCase
          switch level
            when 'warning' then level = 'warn'
            when 'debug' then level = 'log'

          @logger.log level, row.message
