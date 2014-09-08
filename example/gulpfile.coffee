gulp = require 'gulp'
optimize = require '../src/'

gulp.task 'default', ->
  optimize 'a.js', 'optimized.js'
  .pipe gulp.dest './dest/'

