module.exports = (grunt) ->

  pkg = grunt.file.readJSON('package.json')

  require('matchdep').filterDev('grunt-contrib*').forEach(grunt.loadNpmTasks)

  # Project configuration.
  grunt.initConfig

    pkg: pkg

    meta:
      banner: '/*!\n * <%= pkg.title %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      ' * <%= pkg.homepage %>/\n' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
      '<%= pkg.author.name %> <<%= pkg.author.url %>>\n */\n'

    clean:
      options:
        force: true
      runner: pkg.directories.build

    coffee:
      runner:
        options:
          join: true
          bare: false

        files:
          '<%= pkg.directories.build %>/<%= pkg.name %>.js': '<%= pkg.directories.build %>/<%= pkg.name %>.coffee'

      tests:
        expand: true
        options:
          bare: true
        flatten: false
        cwd: '<%= pkg.directories.test %>/'
        src: '**/*.coffee'
        dest: '<%= pkg.directories.test %>/'
        ext: '.js'

    concat:
      coffee:
        src: [
          '<%= pkg.directories.lib %>/utils.coffee'
          '<%= pkg.directories.lib %>/runner.coffee'
          '<%= pkg.directories.lib %>/expose.coffee'
        ]
        dest: '<%= pkg.directories.build %>/<%= pkg.name %>.coffee'

      runner:
        options:
          banner: '<%= meta.banner %>'
          process: true
        src: '<%= pkg.directories.build %>/<%= pkg.name %>.js'
        dest: '<%= pkg.directories.build %>/<%= pkg.name %>.js'

    uglify:
      options:
        banner: '<%= meta.banner %>'
      runner:
        files:
          '<%= pkg.directories.build %>/<%= pkg.name %>-min.js': '<%= concat.runner.dest %>'

    jasmine:
      runner:
        src: '<%= pkg.directories.build %>/<%= pkg.name %>.js'
        options:
          keepRunner: true
          outfile: 'SpecRunner.html'
          vendor: [
            'components/jquery/jquery.js'
          ]
          specs: '<%= pkg.directories.test %>/tests/*Spec.js'
          helpers: [
            '<%= pkg.directories.test %>/helpers/*.js',
            'components/jasmine-sinon/lib/sinon-1.0.0/sinon-1.0.0.js',
            'components/jasmine-sinon/lib/jasmine-sinon.js'
          ]

      release:
        src: '<%= pkg.directories.build %>/<%= pkg.name %>-min.js'
        options:
          keepRunner: true
          outfile: 'SpecRunner.html'
          vendor: [
            'components/jquery/jquery.js'
          ]
          specs: '<%= pkg.directories.test %>/tests/*Spec.js'
          helpers: [
            '<%= pkg.directories.test %>/helpers/*.js',
            'components/jasmine-sinon/lib/sinon-1.0.0/sinon-1.0.0.js',
            'components/jasmine-sinon/lib/jasmine-sinon.js'
          ]


  grunt.registerTask 'default', [
    'clean:runner'
    'concat:coffee'
    'coffee:runner'
    'concat:runner'
  ]

  grunt.registerTask 'release', [
    'default'
    'uglify:runner'
  ]

  grunt.registerTask 'test', [
    'default'
    'coffee:tests'
    'jasmine:runner'
  ]

  grunt.registerTask 'test-release', [
    'release'
    'coffee:tests'
    'jasmine:release'
  ]
