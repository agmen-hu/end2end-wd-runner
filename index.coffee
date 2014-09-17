#!/usr/bin/env coffee

fs = require 'fs'
program = require 'commander'

program
  .option '-c --config <path>', 'path to config yml. Default is root/config.yml'
  .option '-b --browser <firefox|chrome|phantomjs>', 'Default is come from the config'
  .option '-r --root <directory>', 'root directory for text search. Default is end2endTests'
  .option '-g --grep <pattern>', 'regexp matcher for wich tests executed'
  .parse process.argv

root = if program.root then program.root else 'end2endTests'
root = do process.cwd + '/' + root if root.indexOf '/' isnt -1
root += '/'

configParser = new (require './lib/configParser')
configPath = if program.config then program.config else root + '/config.yml'

config = configParser.load __dirname + '/config.yml'
config = configParser.load configPath, config

config.browser.browserName = if program.browser then program.browser else config.browser.browserName
config.root = root

testFiles = []
files = (require 'glob').sync root + '**/*Test.coffee'

if program.grep
  testFiles.push file for file in files when file.match new RegExp program.grep
else
  testFiles = files

runner = new (require './lib/runner') testFiles, config
selenium = new (require './lib/selenium') runner, config
