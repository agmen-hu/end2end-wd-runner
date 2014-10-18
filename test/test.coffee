path = require 'path'
Yadda = require 'yadda'
do Yadda.plugins.mocha.StepLevelPlugin.init

require_feature_libraries = (name, feature) ->
  libraries = if feature.annotations.libraries then feature.annotations.libraries.split(', ') else [ name ]
  libraries.reduce require_library, []

require_library = (libraries, library) ->
  libraries.concat require "./libraries/#{library}Steps"

new Yadda.FeatureFileSearch('./test/features').each (file) ->
  featureName = path.basename file, '.feature'

  featureFile file, (feature) ->
    libraries = require_feature_libraries featureName, feature
    yadda = new Yadda.Yadda libraries

    scenarios feature.scenarios, (scenario) ->
      describe '', ->
        after ->
          do library.afterEach for library in libraries when library.afterEach
          console.log ''

        steps scenario.steps, (step) ->
          yadda.yadda step

