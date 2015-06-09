module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee: [
      expand: true
      cwd: 'src/'
      src: ['**/*.coffee']
      dest: 'build/src/'
      ext: '.js'
    ]
    copy: [
      expand: true
      cwd: 'src/'
      src: ['**/*.js']
      dest: 'build/src/'
    ,
      expand: true
      cwd: 'src/html'
      src: ['**/*']
      dest: 'build/'
    ]
    uglify: 
      options: 
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
        sourceMap: true
        mangle:
          sort: true
          toplevel: true
          eval: true
      files:
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'
    browserify:
      files:
        src: 'build/src/Client.js'
        dest: 'build/<%= pkg.name %>.js'

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask 'default', ['coffee', 'copy', 'browserify', 'uglify']
