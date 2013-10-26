/*
 * html-modules
 * https://github.com/legomushroom/grunt-plugin
 *
 * Copyright (c) 2013 LegoMushroom
 * Licensed under the MIT license.
 */

'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    autoprefixer: {
      dist: {
        options: {
          browsers: ['last 3 version']
        },
        files: {
          'css/main.css': ['css/**/*.css']
        }
      }
    },
    watch: {
        styles: {
            files: ['css/**/*.css'],
            tasks: ['autoprefixer']
        }
    }
  });

  grunt.loadNpmTasks('grunt-autoprefixer');
  grunt.loadNpmTasks('grunt-contrib-watch');

};
