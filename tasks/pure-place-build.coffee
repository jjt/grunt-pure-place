###
 Builds SCSS placeholders and classes from the built Pure css instead of
 the src/ dir.
###
module.exports = (grunt) ->
  grunt.registerMultiTask "pure-place-build", "Builds SCSS files with placeholders.", ->
    _ = grunt.util._
    purePlaceRework = require("../lib/pure-place-rework")
    cleancss = require("clean-css")
    
    options = @options()
    options.toString = options.toString or {}
    options.use = options.use or []
    options.vendors = options.vendors or []
    options.dest = options.dest or @dest or "scss"

    grunt.verbose.writeflags options, "Options"
    async = grunt.util.async
    done = @async()

    foundFiles = []
    placeholderFiles = []
    classesFiles = []

    placeholdersPath = "#{options.dest}/placeholders"
    classesPath = "#{options.dest}/classes"

    async.forEach @files, (file, next) ->
      src = (if _.isFunction(file.src) then file.src() else file.src)
      srcFiles = grunt.file.expand(src)
      
      # Process each file
      fileFn = (srcFile, nextF) ->
         
        # Get filename and strip extension
        filename = srcFile.split("/").pop().split('.').slice(0,-1).join('.')

        # See if it's a file we're interested in
        # That would be [module].css and [module]-nr.css
        numDashes = filename.match(/-/g)?.length
        if numDashes? and (filename.indexOf('-nr') == -1 || filename.indexOf('-nr-min') != -1)
          console.log "#{filename} didn't make it"
          return nextF()
        
        # Build up filenames for _pure-placeholders.scss and _pure-classes.scss
        foundFiles.push filename
        
        # Rework does all of the transformation
        srcCode = grunt.file.read(srcFile)
        cleancssObj = keepBreaks: true

        placeholder_css = purePlaceRework.getPlaceholderCSS(srcCode, toString)
        #placeholder_css = cleancss.process(placeholder_css, cleancssObj)
        placeholderFilepath = "#{placeholdersPath}/_#{filename}.scss"
        grunt.file.write placeholderFilepath, placeholder_css
        grunt.log.oklns "File \"" + placeholderFilepath + "\" created."

        classes_css = purePlaceRework.getPureClassesCSS(srcCode, toString)
        #classes_css = cleancss.process(classes_css, cleancssObj);
        classesFilepath = "#{classesPath}/_#{filename}.scss"
        grunt.file.write classesFilepath, classes_css
        grunt.log.oklns "File \"" + classesFilepath + "\" created."

        nextF()

      filesDoneFn = (err) ->
        if err
          grunt.log.writeln err
          return next()

        # Copy grid utility files
        filesToCopy = ["_grid-functions.scss", "_grid-classes.scss"]

        for filename in filesToCopy
          grunt.file.copy __dirname + "/../lib/#{filename}",
            options.dest + "/#{filename}"
        

        placeholders_dest = "#{options.dest}/_pure-placeholders.scss"
        placeholders_dest_nr = placeholders_dest.replace(/.scss$/, '-nr.scss')
        classes_dest = "#{options.dest}/_pure-classes.scss"
        classes_dest_nr = classes_dest.replace(/.scss$/, '-nr.scss')

        # Master file that @imports all of the modules
        outPlaceholders = outPlaceholdersNR =
          "// Pure built as SASS placeholders\n\n"
        outClasses = outClassesNR =
          "// Pure built as SASS classes with a custom prefix
           // Default prefix\n$pure-classes-prefix: pure !default;\n\n"

        for file in foundFiles.filter((item) -> item.indexOf("-nr") == -1)
          outPlaceholders += "@import \"placeholders/#{file}\";\n"
          outClasses += "@import \"classes/#{file}\";\n"

        grunt.file.write placeholders_dest, outPlaceholders
        grunt.log.oklns "File " + placeholders_dest + " created"

        grunt.file.write classes_dest, outClasses
        grunt.log.oklns "File " + classes_dest + " created"

        add_nrs = (str) ->
          str.replace('forms', 'forms-nr')
            .replace('grids', 'grids-nr')
            .replace('menus', 'menus-nr')

        grunt.file.write placeholders_dest_nr, add_nrs(outPlaceholders)
        grunt.log.oklns "File #{placeholders_dest_nr} created"

        grunt.file.write classes_dest_nr, add_nrs(outClasses)
        grunt.log.oklns "File #{classes_dest_nr} created"

        next()

      async.forEach srcFiles, fileFn.bind(this), filesDoneFn.bind(this), done


