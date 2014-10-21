path = require 'path'
Yadda = require 'yadda'

do (require 'chai').should
do Yadda.plugins.mocha.StepLevelPlugin.init

process.env.MOCHA_REPORTER_STACK_EXCLUDE = '(\/yadda\/lib\/)|(\/test\/test.coffee)'

module.exports = class Runner

  run: (requestedFeature) ->
    new Yadda.FeatureFileSearch('./test/features').each (file) =>
      featureName = path.basename file, '.feature'

      return if requestedFeature and featureName isnt requestedFeature

      featureFile file, (feature) =>
        libraries = @requireFeatureLibraries featureName, feature
        yadda = new Yadda.Yadda libraries

        scenarios feature.scenarios, (scenario) ->
          describe '', ->
            context = context: {}

            after ->
              library.afterEach.apply context for library in libraries when library.afterEach

            steps scenario.steps, (step) ->
              yadda.yadda step, context

  requireFeatureLibraries: (name, feature) ->
    libraries = if feature.annotations.libraries then feature.annotations.libraries.split(', ') else [ name ]
    libraries.reduce @requireLibrary, []

  requireLibrary: (libraries, library) =>
    libraries.concat require "./libraries/#{library}Steps"
