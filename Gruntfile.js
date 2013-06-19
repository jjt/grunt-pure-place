// grunt-pure-place
// ----------
// A Grunt task that consumes Pure/src/**/css/*.css and creates Sass placeholders
// Based off of https://github.com/jney/grunt-rework
 
module.exports = function(grunt) {

  grunt.initConfig({
    'pure-place-build': {
      files: 'build/*.css',
      options: {
        dest: 'scss-build'
      }
    },
    'pure-place-src': {
      files: 'src/**/css/*.css',
      options: {
        dest: 'scss'
      }
    }
  });

  grunt.loadTasks('tasks');

  grunt.registerTask('pure-place-src', ['pure-place-src']);
  grunt.registerTask('pure-place-build', ['pure-place-build']);

  grunt.registerTask('default', 'pure-place-build');

}
