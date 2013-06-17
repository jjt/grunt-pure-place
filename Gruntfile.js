// grunt-pure-place
// ----------
// A Grunt task that consumes Pure/src/**/css/*.css and creates Sass placeholders
// Based off of https://github.com/jney/grunt-rework
 
module.exports = function(grunt) {
  
  // NPM link won't pick up this package locally on my box
  // So for now, see if we got called by one of these methods:
  // 
  // grunt.loadNpmTasks('pure-place')
  // require('pure-place')(grunt)
  

  grunt.initConfig({
    'pure-place': {
      files: 'src/**/css/*.css',
      dest: 'scss'
    }
  });
  grunt.loadTasks('tasks');
  grunt.registerTask('default', 'pure-place');

}
