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
  var gruntLoaded = Object.keys(grunt.config.data).length > 0,
    initConfigObj = {
      files: 'src/**/css/*.css',
      dest: 'scss'
    }

  if(gruntLoaded)
    grunt.config.set('pure-place', initConfigObj);
  else
    grunt.initConfig({
      'pure-place': initConfigObj
    });
    
  grunt.registerMultiTask('pure-place', 'Builds SCSS files with placeholders.', function () {
    var _ = grunt.util._;
    var rework = require('rework');
    var options = this.options();
    options.toString = options.toString || {};
    options.use = options.use || [];
    options.vendors = options.vendors || [];
    options.dest = options.dest || this.dest || 'scss';


    grunt.verbose.writeflags(options, 'Options');

    var async = grunt.util.async;
    var done = this.async();

    var placeholderFiles = {},
      classesFiles = {};

    async.forEach(this.files, function(file, next) {
      var src = _.isFunction(file.src) ? file.src() : file.src;
      var srcFiles = grunt.file.expand(src);

      var fileFn,filesDoneFn;

      // Process each file
      fileFn = function(srcFile, nextF) {
        var srcCode = grunt.file.read(srcFile);

        // Rework does all of the transformation
        var purePlaceRework = require('./lib/pure-place-rework'),
          cleancss = require('clean-css');
        
        // Generate placeholders file path
        var pathArr = srcFile.split('/');
        pathArr[0] = options.dest;
        pathArr.splice(2,1);
        var filename = pathArr.pop();
        filename = "_" + filename.replace(/css$/, 'scss');
        pathArr.push(filename);
        var placeholder_dest = pathArr.join('/');


        // Build up filenames for _pure-placeholders.scss
        var folder = pathArr[1];
        if(placeholderFiles[folder] === undefined)
          placeholderFiles[folder] = [];
        placeholderFiles[folder].push(pathArr[2]);

        // Generate pure extended classes filepath
        pathArr.push(pathArr.pop().replace(/\.scss$/, '-classes.scss')); 
        var classes_dest = pathArr.join('/');

        // Build up filenames for _pure-classes.scss
        var folder = pathArr[1];
        if(classesFiles[folder] === undefined)
          classesFiles[folder] = [];
        classesFiles[folder].push(pathArr[2]);
        


        var cleancssObj = {
          keepBreaks:true
        }
        var placeholder_css = purePlaceRework.getPlaceholderCSS(srcCode, toString);
        placeholder_css = cleancss.process(placeholder_css, cleancssObj);

        grunt.file.write(placeholder_dest, placeholder_css);
        grunt.log.oklns('File "' + placeholder_dest + '" created.');

        var classes_css = purePlaceRework.getPureClassesCSS(srcCode, toString);
        //classes_css = cleancss.process(classes_css, cleancssObj);

        grunt.file.write(classes_dest, classes_css);
        grunt.log.oklns('File "' + classes_dest + '" created.');

        nextF()
      }
        
      filesDoneFn = function(err){
        if(err) {
          grunt.log.writeln(err);
          return next();
        }

        // Master file that @imports all of the modules
        var placeholders_dest = "scss/_pure-placeholders.scss",
            classes_dest = "scss/_pure-classes.scss";

        var out = "// Pure built as SASS placeholders\n\n";
        for(k in placeholderFiles) {
          var v = placeholderFiles[k]; 
          if(!placeholderFiles.hasOwnProperty(k))
            continue;
          // Handle the base files differently
          if(k === 'base') {
            out += "// Copy this line to mystyles.scss and uncomment\n";
            out += "//@import \"base/normalize\";\n\n";
            out += "@import \"base/normalize-context\";\n";
            out += "\n";
            continue;
          }
          out += "/* " + k[0].toUpperCase() + k.substr(1) + "*/\n";
          placeholderFiles[k].forEach(function(filename) {
            out += '@import "' + k + "/" + filename.substr(1) + "\";\n";
          });

        }

        grunt.file.write(placeholders_dest,out);
        grunt.log.oklns('File ' + placeholders_dest + ' created');


        var out = "// Pure built as SASS classes with a custom prefix\n\n";
        out += "// Default prefix\n$pure-classes-prefix: pure !default;\n\n";
        for(k in classesFiles) {
          var v = classesFiles[k]; 
          if(!classesFiles.hasOwnProperty(k))
            continue;
          out += "/* " + k[0].toUpperCase() + k.substr(1) + "*/\n";
          classesFiles[k].forEach(function(filename) {
            out += '@import "' + k + "/" + filename.substr(1) + "\";\n";
          });
        }

        grunt.file.write(classes_dest,out);
        grunt.log.oklns('File ' + classes_dest + ' created');



        next();
      }

      async.forEach(srcFiles, fileFn.bind(this), filesDoneFn.bind(this), done);
    });
  });

  if(gruntLoaded) 
    grunt.registerTask('default', 'pure-place');

}
