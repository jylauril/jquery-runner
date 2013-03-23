/*global module:false*/
module.exports = function(grunt) {

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');

    // Project configuration.
    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json'),

        meta: {
            banner: '/*!\n * <%= pkg.title %> - v<%= pkg.version %> - ' +
                '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
                ' * <%= pkg.homepage %>/\n' +
                ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
                '<%= pkg.author.name %> <<%= pkg.author.url %>>\n */\n'
        },

        clean: {
            options: {
                force: true
            },
            build: ["build"]
        },

        coffee: {
            lib: {
                 options: {
                    join: true,
                    bare: false
                },
                files: {
                    '<%= pkg.directories.build %>/<%= pkg.name %>.js': [
                        '<%= pkg.directories.lib %>/utils.coffee',
                        '<%= pkg.directories.lib %>/runner.coffee',
                        '<%= pkg.directories.lib %>/expose.coffee'
                    ]
                }
            },
        },

        concat: {
            finish: {
                options: {
                    banner: '<%= meta.banner %>',
                    process: true
                },
                src: ['<%= pkg.directories.build %>/<%= pkg.name %>.js'],
                dest: '<%= pkg.directories.build %>/<%= pkg.name %>.js'
            }
        },

        uglify: {
            options: {
                banner: '<%= meta.banner %>'
            },
            lib: {
                files: {
                    '<%= pkg.directories.build %>/<%= pkg.name %>-min.js': '<%= concat.finish.dest %>'
                }
            }
        }
    });

    grunt.registerTask('default', ['clean', 'coffee', 'concat']);
    grunt.registerTask('release', ['default', 'uglify']);
    grunt.registerTask('lib', ['coffee', 'concat']);
};