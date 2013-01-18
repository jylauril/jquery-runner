/*global module:false*/
module.exports = function(grunt) {

    grunt.loadNpmTasks('grunt-contrib');
    grunt.loadNpmTasks('grunt-coffee');

    // Project configuration.
    grunt.initConfig({

        pkg: '<json:package.json>',

        meta: {
            banner: '/*!\n * <%= pkg.title %> - v<%= pkg.version %> - ' +
                '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
                ' * <%= pkg.homepage %>/\n' +
                ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
                '<%= pkg.author.name %> <<%= pkg.author.url %>>\n */',

            lib: {
                intro: ';(function($) {\n' +
                    'var meta = { ' +
                        'version: "<%= pkg.version %>", ' +
                        'name: "<%= pkg.title %>" ' +
                    '};',
                outro: '})(window.jQuery);'
            }
        },

        clean: {
            files: ['build/**/*']
        },

        coffee: {
            lib: {
                src: '<%= pkg.directories.lib %>/**/*.coffee',
                options: {
                    preserve_dirs: true
                }
            }
        },

        concat: {
            lib: {
                src: [
                    '<banner:meta.banner>',
                    '<banner:meta.lib.intro>',
                    '<%= pkg.directories.lib %>/utils.js',
                    '<%= pkg.directories.lib %>/runner.js',
                    '<%= pkg.directories.lib %>/expose.js',
                    '<banner:meta.lib.outro>'
                ],
                dest: '<%= pkg.directories.build %>/<%= pkg.name %>.js'
            }
        },

        min: {
            lib: {
                src: ['<banner:meta.banner>', '<config:concat.lib.dest>'],
                dest: '<%= pkg.directories.build %>/<%= pkg.name %>-min.js'
            }
        },

        watch: {
            coffee: {
                files: '<config:coffee.lib.src>',
                tasks: 'coffee'
            }
        }
    });

    grunt.registerTask('default', 'clean coffee concat');
    grunt.registerTask('minify', 'min');
    grunt.registerTask('release', 'default minify');
    grunt.registerTask('lib', 'coffee:lib concat:lib');
    grunt.registerTask('lib-min', 'concat:lib min:lib');
};
