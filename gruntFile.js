require('coffee-script/register');

module.exports = function(grunt) {
  var
  MochaTester = {

    path: require('path'),
    fs: require('fs'),

    registerToWatchTask: function(target, mochaOptions){
      var tester = Object.create(this);

      tester.target = target;
      grunt.event.on("watch", tester.listener.bind(tester));

      return tester;
    },

    listener: function(action, filepath, target)
    {
      if (!this.isListenedEvent(action, target)) {
        return;
      }

      var ext;
      if (filepath.indexOf('.feature') != -1) {
        ext = '.feature'
      } else if (filepath.indexOf('Steps.coffee') != -1) {
        ext = 'Steps.coffee'
      } else {
        ext = '.coffee'
      }

      process.env.REQUIRED_FEATURE = this.path.basename(filepath, ext);

      this.clearCache(filepath);
      this.clearCache('test/test.coffee');
      this.clearCache('test/library.coffee');
      this.createMocha();

      setTimeout(this.run.bind(this), 500);
    },

    isListenedEvent: function(action, target)
    {
      return action == 'changed' && target == this.target;
    },

    clearCache: function(filepath)
    {
      require.cache[require.resolve('./'+filepath)] = undefined;
    },

    createMocha: function()
    {
      this.mocha = new (require('mocha'))({
        reporter: 'dot'
      });
      this.mocha.addFile('test/test.coffee');
    },

    run: function()
    {
      this.mocha.run(function(failureCount){
        if (failureCount) {
          grunt.log.error('falling: ' + failureCount)
        } else {
          grunt.log.ok('OK');
        }
      });
    }
}

  grunt.initConfig({
    watch: {
      automatic: {
        files: [
          'src/**/*.coffee',
          'test/features/*.feature',
          'test/libraries/*.coffee'
          ],
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');

  MochaTester.registerToWatchTask('automatic');
}
