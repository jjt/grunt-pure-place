module.exports = (grunt) ->
  grunt.registerMultiTask "pure-place", "Builds SCSS files with placeholders.", ->
    _ = grunt.util._
    rework = require("rework")
    options = @options()
    options.toString = options.toString or {}
    options.use = options.use or []
    options.vendors = options.vendors or []
    options.dest = options.dest or @dest or "scss"
    grunt.verbose.writeflags options, "Options"
    async = grunt.util.async
    done = @async()
    placeholderFiles = {}
    classesFiles = {}
    async.forEach @files, (file, next) ->
      src = (if _.isFunction(file.src) then file.src() else file.src)
      srcFiles = grunt.file.expand(src)
      fileFn = undefined
      filesDoneFn = undefined
      
      # Process each file
      fileFn = (srcFile, nextF) ->
        srcCode = grunt.file.read(srcFile)
        
        # Rework does all of the transformation
        purePlaceRework = require("../lib/pure-place-rework")
        cleancss = require("clean-css")
        
        # Generate placeholders file path
        pathArr = srcFile.split("/")
        pathArr[0] = options.dest
        pathArr.splice 2, 1
        filename = pathArr.pop()
        filename = "_" + filename.replace(/css$/, "scss")
        pathArr.push filename
        placeholder_dest = pathArr.join("/")
        
        # Build up filenames for _pure-placeholders.scss
        folder = pathArr[1]
        placeholderFiles[folder] = []  if placeholderFiles[folder] is `undefined`
        placeholderFiles[folder].push pathArr[2]
        
        # Generate pure extended classes filepath
        pathArr.push pathArr.pop().replace(/\.scss$/, "-classes.scss")
        classes_dest = pathArr.join("/")
        
        # Build up filenames for _pure-classes.scss
        folder = pathArr[1]
        classesFiles[folder] = []  if classesFiles[folder] is `undefined`
        classesFiles[folder].push pathArr[2]
        cleancssObj = keepBreaks: true
        placeholder_css = purePlaceRework.getPlaceholderCSS(srcCode, toString)
        placeholder_css = cleancss.process(placeholder_css, cleancssObj)
        grunt.file.write placeholder_dest, placeholder_css
        grunt.log.oklns "File \"" + placeholder_dest + "\" created."
        classes_css = purePlaceRework.getPureClassesCSS(srcCode, toString)
        
        #classes_css = cleancss.process(classes_css, cleancssObj);
        grunt.file.write classes_dest, classes_css
        grunt.log.oklns "File \"" + classes_dest + "\" created."
        nextF()

      filesDoneFn = (err) ->
        if err
          grunt.log.writeln err
          return next()

        filesToCopy = ["_grid-functions.scss", "_grid-classes.scss"]

        for filename in filesToCopy
          grunt.file.copy __dirname + "/../lib/#{filename}",
            options.dest + "/#{filename}"
        
        # Master file that @imports all of the modules
        placeholders_dest = "#{options.dest}/_pure-placeholders.scss"
        classes_dest = "#{options.dest}/_pure-classes.scss"
        out = "// Pure built as SASS placeholders\n\n"
        for k of placeholderFiles
          v = placeholderFiles[k]
          continue  unless placeholderFiles.hasOwnProperty(k)
          
          # Handle the base files differently
          if k is "base"
            out += "// Copy this line to mystyles.scss and uncomment\n"
            out += "//@import \"base/normalize\";\n\n"
            out += "@import \"base/normalize-context\";\n"
            out += "\n"
            continue
          out += "/* " + k[0].toUpperCase() + k.substr(1) + "*/\n"
          placeholderFiles[k].forEach (filename) ->
            out += "@import \"" + k + "/" + filename.substr(1) + "\";\n"

        grunt.file.write placeholders_dest, out
        grunt.log.oklns "File " + placeholders_dest + " created"
        out = "// Pure built as SASS classes with a custom prefix\n\n"
        out += "// Default prefix\n$pure-classes-prefix: pure !default;\n\n"
        for k of classesFiles
          v = classesFiles[k]
          continue  unless classesFiles.hasOwnProperty(k)
          out += "/* " + k[0].toUpperCase() + k.substr(1) + "*/\n"
          classesFiles[k].forEach (filename) ->
            out += "@import \"" + k + "/" + filename.substr(1) + "\";\n"

        grunt.file.write classes_dest, out
        grunt.log.oklns "File " + classes_dest + " created"
        next()

      async.forEach srcFiles, fileFn.bind(this), filesDoneFn.bind(this), done


