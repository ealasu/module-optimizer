gulp = require 'gulp'
optimize = require '..'

gulp.task 'default', ->
  optimize 'a.js', 'optimized.js'
  .pipe gulp.dest './dest/'

